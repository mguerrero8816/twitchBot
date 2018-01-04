module TwitchConnector
  attr_reader :logger, :running, :socket

  TWITCH_USER = Rails.application.secrets['twitch_bot_user'].freeze
  TWITCH_PASS = Rails.application.secrets['twitch_bot_pass'].freeze
  TWITCH_SERVER = 'irc.chat.twitch.tv'.freeze
  TWITCH_PORT = 6667.freeze
  COMMAND_TIME_LIMIT = 5.freeze # time in seconds to command cooldown

  def send_channel_message(target_channel_name, message)
    send_command("PRIVMSG ##{target_channel_name} :#{message}")
  end

  def queue_channel_message(message)
    @messages << message
  end

  def disconnect
    @running = false
    @socket  = nil
    self.update_attribute('intended_status_id', 0)
    self.update_attribute('live_status_id', 0)
    if !channel_name.blank?
      channel_name.downcase!
      twitch_bot_threads = Thread.list.select{|thread| thread['bot_id'] == id || ( thread[:channel_name] == channel_name && thread[:bot_name] == bot_name ) }
      twitch_bot_threads.each{|thread| thread.kill}
    end
    kill_repeaters
    kill_channel_messenger
  end

  def connect
    initialize_connection
    self.update_attribute('intended_status_id', 1)
    Thread.start do
      commands_data = build_commands_data
      commands_list = commands_data.keys
      custom_commands_data = build_custom_commands_data
      custom_commands_list = custom_commands_data.keys
      cached_channel_name = channel_name
      cached_bot_name = bot_name
      cached_bot_id = id
      initialize_channel_messenger(cached_channel_name, cached_bot_name, cached_bot_id)
      moderator_list = Moderator.where(channel_id: channel_id).map(&:name)
      moderator_list << cached_channel_name
      Thread.current["channel_name"] = cached_channel_name
      Thread.current["bot_name"] = cached_bot_name
      Thread.current["bot_id"] = cached_bot_id

      commands_data.each do |_, command_settings|
        if command_settings.repeater_status_id == 1 && command_settings.repeater_cycle_seconds > 0 && (command_settings.repeater_start_at.nil? || command_settings.repeater_start_at <= Time.zone.now)
          spawn_command_repeater(cached_channel_name, cached_bot_name, cached_bot_id, command_settings)
        end
      end

      custom_commands_data.each do |_, custom_command_settings|
        if custom_command_settings.repeater_status_id == 1 && custom_command_settings.repeater_cycle_seconds > 0 && (custom_command_settings.repeater_start_at.nil? || custom_command_settings.repeater_start_at <= Time.zone.now)
          spawn_custom_command_repeater(cached_channel_name, cached_bot_name, cached_bot_id, custom_command_settings)
        end
      end

      while (@running) do
        ready = IO.select([@socket])
        ready[0].each do |s|
          line    = s.gets
          match   = line.match(/^:(.+)!(.+) PRIVMSG #(.+) :(.+)$/)
          user    = match.try(:[], 1)
          message = match.try(:[], 4)
          channel = line.split('PRIVMSG #').last.split(' :').first
          message = message.to_s.strip
          command_key = message
          command_key[0] = ''
          command_key = command_key.to_sym
          @logger.info "USER COMMAND: #{user} - #{message}"

          if line.include?('PING :tmi.twitch.tv')
            send_pong_response
          elsif commands_list.include?(command_key)
            send_channel_command(cached_channel_name, moderator_list.include?(user), commands_data[command_key])
          elsif custom_commands_list.include?(command_key)
            send_channel_custom_command(cached_channel_name, moderator_list.include?(user), custom_commands_data[command_key])
          end
          @logger.info "> #{line}"
        end
      end
    end
  end

  private

  def initialize_connection
    # terminate existing threads connected to the same channel and bot
    disconnect
    @logger  = Logger.new(STDOUT)

    @logger.info 'Preparing to connect...'
    @socket = TCPSocket.new(TWITCH_SERVER, TWITCH_PORT)
    @running = true

    @socket.puts("PASS #{TWITCH_PASS}")
    @socket.puts("NICK #{TWITCH_USER}")

    @logger.info 'Connected...'
    join_channel
  end

  def send_command(message)
    @logger.info "< #{message}"
    @socket.puts(message)
  end

  def join_channel
    send_command("JOIN ##{channel_name}")
  end

  def build_commands_data
    commands_list = TwitchBotCommands.methods(false)
    command_settings = (
      CommandPermission.select('command_permissions.command_name AS command_name,
                                COALESCE(command_permissions.id, 0) AS command_permission_id,
                                COALESCE(command_permissions.permission_id, 0) AS permission_id,
                                COALESCE(command_repeaters.id, 0) AS command_repeater_id,
                                COALESCE(command_repeaters.status_id, 0) AS repeater_status_id,
                                COALESCE(command_repeaters.cycle_seconds, 0) AS repeater_cycle_seconds,
                                command_repeaters.start_at AS repeater_start_at')
                       .joins('LEFT JOIN command_repeaters ON command_permissions.command_name = command_repeaters.command_name AND command_permissions.channel_id = command_repeaters.channel_id')
                       .where('command_permissions.channel_id = ? AND command_permissions.command_name IN (?) AND command_permissions.command_id IS NULL', channel_id, commands_list)
    )
    permissions = CommandPermission.where('command_id IS NULL AND command_name IN (?) AND channel_id = ?', commands_list, channel_id)
    Struct.new('CommandSettings', :command_name, :last_used, :permission_id, :repeater_status_id, :repeater_cycle_seconds, :repeater_start_at)
    command_settings_data = {}
    command_settings.each do |command_setting|
      name_key = command_setting.command_name.to_sym
      command_settings_data[name_key] = Struct::CommandSettings.new(name_key, Time.zone.now-COMMAND_TIME_LIMIT.seconds, command_setting.permission_id, command_setting.repeater_status_id, command_setting.repeater_cycle_seconds, command_setting.repeater_start_at)
    end
    commands_data = {}
    commands_list.each do |command_name|
      name_key = command_name.to_sym
      commands_data[name_key] = command_settings_data[name_key] || Struct::CommandSettings.new(name_key, Time.zone.now-COMMAND_TIME_LIMIT.seconds, 0, 0, 0, nil)
    end
    commands_data
  end

  def build_custom_commands_data
    custom_commands_list = (
      CustomCommand.select('custom_commands.*,
                            command_permissions.permission_id AS command_permission_id,
                            COALESCE(command_repeaters.status_id, 0) AS repeater_status_id,
                            COALESCE(command_repeaters.cycle_seconds, 0) AS repeater_cycle_seconds,
                            command_repeaters.start_at AS repeater_start_at')
                   .joins('LEFT JOIN command_repeaters ON custom_commands.id = command_repeaters.command_id')
                   .joins('LEFT JOIN command_permissions ON custom_commands.id = command_permissions.command_id')
                   .where('custom_commands.channel_id = ?', channel_id)
    )
    custom_commands_data = {}
    Struct.new('CustomCommandSettings', :response, :last_used, :permission_id, :repeater_status_id, :repeater_cycle_seconds, :repeater_start_at)
    custom_commands_list.each do |custom_command|
      name_key = custom_command.command.to_sym
      custom_commands_data[name_key] = Struct::CustomCommandSettings.new(custom_command.response, Time.zone.now-COMMAND_TIME_LIMIT.seconds, custom_command.command_permission_id, custom_command.repeater_status_id, custom_command.repeater_cycle_seconds, custom_command.repeater_start_at)
    end
    custom_commands_data
  end

  def send_pong_response
    puts 'Pinged, responding with PONG'
    send_command "PONG :tmi.twitch.tv"
    ChannelBot.find(id).update_attribute('live_status_id', 1)
  end

  def send_channel_command(cached_channel_name, is_admin, command_settings)
    if command_permitted(command_settings, is_admin)
      bot_messages = [TwitchBotCommands.try(command_settings.try(:command_name))].flatten
      bot_messages.each{|bot_message| queue_channel_message(bot_message) }
      command_settings.last_used = Time.zone.now
    end
  end

  def send_channel_custom_command(cached_channel_name, is_admin, command_settings)
    if command_permitted(command_settings, is_admin)
      queue_channel_message(command_settings.response)
      command_settings.last_used = Time.zone.now
    end
  end

  # permit command if set to all or set to admins and sent by admins
  def command_permitted(command_settings, is_admin)
    (command_settings.permission_id == 1 || (command_settings.permission_id == 0 && is_admin)) && command_settings.last_used < (Time.zone.now - COMMAND_TIME_LIMIT.seconds)
  end

  def spawn_command_repeater(cached_channel_name, cached_bot_name, cached_bot_id, command_settings)
    Thread.new do
      Thread.current['type'] = 'command_repeater'
      Thread.current["channel_name"] = cached_channel_name
      Thread.current["bot_name"] = cached_bot_name
      Thread.current["bot_id"] = cached_bot_id
      sleep command_settings.repeater_cycle_seconds
      bot_messages = [ TwitchBotCommands.try(command_settings.command_name) ].flatten
      bot_messages.each{ |bot_message| queue_channel_message(bot_message) }
      spawn_command_repeater(cached_channel_name, cached_bot_name, cached_bot_id, command_settings)
    end
  end

  def spawn_custom_command_repeater(cached_channel_name, cached_bot_name, cached_bot_id, command_settings)
    Thread.new do
      Thread.current['type'] = 'command_repeater'
      Thread.current["channel_name"] = cached_channel_name
      Thread.current["bot_name"] = cached_bot_name
      Thread.current["bot_id"] = cached_bot_id
      sleep command_settings.repeater_cycle_seconds
      queue_channel_message(command_settings.response)
      spawn_custom_command_repeater(cached_channel_name, cached_bot_name, cached_bot_id, command_settings)
    end
  end

  def kill_repeaters
    repeater_threads = Thread.list.select{|thread| (thread[:bot_id] == id || ( thread[:channel_name] == channel_name && thread[:bot_name] == bot_name )) && thread[:type] == 'command_repeater' }
    repeater_threads.each{|thread| thread.kill}
  end

  def initialize_channel_messenger(cached_channel_name, cached_bot_name, cached_bot_id)
    @messages = []
    spawn_channel_messenger(cached_channel_name, cached_bot_name, cached_bot_id)
  end

  # this repeater sends messages to the channel every other second
  def spawn_channel_messenger(cached_channel_name, cached_bot_name, cached_bot_id)
    Thread.new do
      Thread.current['type'] = 'channel_messenger'
      Thread.current["channel_name"] = cached_channel_name
      Thread.current["bot_name"] = cached_bot_name
      Thread.current["bot_id"] = cached_bot_id
      sleep 2
      if @messages.length > 0
        message = @messages[0]
        send_channel_message(cached_channel_name, message)
        @messages = @messages.drop(1)
      end
      spawn_channel_messenger(cached_channel_name)
    end
  end

  def kill_channel_messenger
    @messages = []
    messenger_thread = Thread.list.select{|thread| (thread[:bot_id] == id || ( thread[:channel_name] == channel_name && thread[:bot_name] == bot_name )) && thread[:type] == 'channel_messenger' }
    messenger_thread.each{|thread| thread.kill}
  end
end
