module TwitchConnector
  attr_reader :logger, :running, :socket

  TWITCH_USER = Rails.application.secrets['twitch_bot_user']
  TWITCH_PASS = Rails.application.secrets['twitch_bot_pass']
  TWITCH_SERVER = 'irc.chat.twitch.tv'
  TWITCH_PORT = 6667
  DEFAULT_BOT_NAME = 'Mikebot'

  def send_channel_message(target_channel_name, message)
    send_command("PRIVMSG ##{target_channel_name} :#{message}")
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
  end

  def connect
    initialize_connection
    self.update_attribute('intended_status_id', 1)
    Thread.start do
      Thread.current["channel_name"] = channel_name
      Thread.current["bot_name"] = bot_name
      Thread.current["bot_id"] = id
      commands_data = build_commands_data
      custom_commands_data = build_custom_commands_data
      commands_list = commands_data.keys
      custom_commands_list = custom_commands_data.keys
      cached_channel_name = channel_name

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
            bot_messages = [TwitchBotCommands.try(command_key)].flatten
            bot_messages.each{|bot_message| send_channel_message(cached_channel_name, bot_message) }
          elsif custom_commands_list.include?(command_key)
            send_channel_message(cached_channel_name, custom_commands_data[command_key].response)
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
    permissions = CommandPermission.where('command_id IS NULL AND command_name IN (?) AND channel_id = ?', commands_list, channel_id)
    Struct.new('CommandSettings', :command_name, :permission_id)
    commands_data = {}
    permissions.each do |permission|
      name_key = permission.command_name.to_sym
      commands_data[name_key] = Struct::CommandSettings.new(name_key, permission.permission_id)
    end
    commands_data
  end

  def build_custom_commands_data
    custom_commands_list = (
      CustomCommand.select('custom_commands.*,
                            command_permissions.permission_id AS command_permission_id')
                   .joins('LEFT JOIN command_permissions ON custom_commands.id = command_permissions.command_id')
                   .where('custom_commands.channel_id = ?', channel_id)
    )
    custom_commands_data = {}
    Struct.new('CommandSettings', :response, :permission_id)
    custom_commands_list.each do |custom_command|
      name_key = custom_command.command.to_sym
      custom_commands_data[name_key] = Struct::CommandSettings.new(custom_command.response, custom_command.command_permission_id)
    end
    custom_commands_data
  end

  def send_pong_response
    puts 'Pinged, responding with PONG'
    send_command "PONG :tmi.twitch.tv"
    ChannelBot.find(id).update_attribute('live_status_id', 1)
  end
end
