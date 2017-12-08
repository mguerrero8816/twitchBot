require 'socket'
require 'logger'

module TwitchConnector
  attr_reader :logger, :running, :socket

  TWITCH_USER = Rails.application.secrets['twitch_bot_user']
  TWITCH_PASS = Rails.application.secrets['twitch_bot_pass']
  TWITCH_SERVER = 'irc.chat.twitch.tv'
  TWITCH_PORT = 6667
  DEFAULT_BOT_NAME = 'Mikebot'

  # class << self
  #   def connect(channel_name, bot_name, bot_id)
  #     if !channel_name.blank?
  #       channel_name.downcase!
  #       bot = new
  #       bot_name = DEFAULT_BOT_NAME if bot_name.blank?
  #       bot.run(channel_name, bot_name, bot_id)
  #       bot.send_command("JOIN ##{channel_name}")
  #     end
  #   end
  #
  #   def disconnect(channel_name, bot_name)
  #     if !channel_name.blank?
  #       channel_name.downcase!
  #       twitch_bot_threads = Thread.list.select{|thread| thread[:channel_name] == channel_name && thread[:bot_name] == bot_name }
  #       twitch_bot_threads.each{|thread| thread.kill}
  #     end
  #   end
  # end

  def send_channel_message(channel_name, message)
    send_command("PRIVMSG ##{channel_name} :#{message}")
  end

  def send_command(message)
    logger.info "< #{message}"
    puts message
    puts socket
    socket.puts(message)
  end

  def disconnect
    @running = false
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
      while (running) do
        ready = IO.select([socket])
        ready[0].each do |s|
          line    = s.gets
          match   = line.match(/^:(.+)!(.+) PRIVMSG #(.+) :(.+)$/)
          sender = match.try(:[], 1)
          message = match.try(:[], 4)
          message = message.to_s.strip
          command_key = message
          command_key[0] = ''
          command_key = command_key.to_sym

          if line.include?('PING :tmi.twitch.tv')
            puts 'Pinged, responding with PONG'
            send_command "PONG :tmi.twitch.tv"
            ChannelBot.find(id).update_attribute('live_status_id', 1)
            # response = Net::HTTP.get(URI(Rails.application.secrets.server_home))
          elsif TwitchBotCommands::DEV_DEFINED_METHODS.include?(command_key)
            user = match[1]
            logger.info "USER COMMAND: #{user} - #{message}"
            bot_messages = [TwitchBotCommands.try(command_key)].flatten
            bot_messages.each{|bot_message| send_channel_message bot_message }
          elsif custom_command = CustomCommand.where('command = ?', command_key.to_s).last
            logger.info "USER COMMAND: #{user} - #{message}"
            send_channel_message custom_command.response
          end
          logger.info "> #{line}"
        end
      end
    end
  end

  private

  def initialize_connection
    # terminate existing threads connected to the same channel and bot
    disconnect
    @logger  = Logger.new(STDOUT)
    @running = false
    @socket  = nil

    logger.info 'Preparing to connect...'
    @socket = TCPSocket.new(TWITCH_SERVER, TWITCH_PORT)
    @running = true

    socket.puts("PASS #{TWITCH_PASS}")
    socket.puts("NICK #{TWITCH_USER}")

    logger.info 'Connected...'
  end
end
