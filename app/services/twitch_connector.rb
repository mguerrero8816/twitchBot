require 'socket'
require 'logger'

module TwitchConnector
  DEFAULT_BOT_NAME = 'Mikebot'

  class << self
    def connect(channel_name, bot_name)
      if !channel_name.blank?
        channel_name.downcase!
        bot = Twitch.new
        bot_name = DEFAULT_BOT_NAME if bot_name.blank?
        bot.run(channel_name, bot_name)
        bot.send("JOIN ##{channel_name}")
      end
    end

    def disconnect(channel_name, bot_name)
      if !channel_name.blank?
        channel_name.downcase!
        twitch_bot_threads = Thread.list.select{|thread| thread[:channel_name] == channel_name && thread[:bot_name] == bot_name }
        twitch_bot_threads.each{|thread| thread.kill}
      end
    end
  end

  class Twitch
    attr_reader :logger, :running, :socket

    TWITCH_USER = Rails.application.secrets['twitch_bot_user']
    TWITCH_PASS = Rails.application.secrets['twitch_bot_pass']
    TWITCH_SERVER = 'irc.chat.twitch.tv'
    TWITCH_PORT = 6667

    def initialize(logger = nil)
      @logger  = logger || Logger.new(STDOUT)
      @running = false
      @socket  = nil
    end

    def send(message)
      logger.info "< #{message}"
      puts message
      puts socket
      socket.puts(message)
    end

    def run(channel_name, bot_name)
      # terminate existing threads connected to the same channel and bot
      TwitchConnector.disconnect(channel_name, bot_name)

      logger.info 'Preparing to connect...'

      @socket = TCPSocket.new(TWITCH_SERVER, TWITCH_PORT)
      @running = true

      socket.puts("PASS #{TWITCH_PASS}")
      socket.puts("NICK #{TWITCH_USER}")

      logger.info 'Connected...'

      Thread.start do
        Thread.current["channel_name"] = channel_name
        Thread.current["bot_name"] = bot_name
        while (running) do
          ready = IO.select([socket])

          ready[0].each do |s|
            line    = s.gets
            match   = line.match(/^:(.+)!(.+) PRIVMSG #(.+) :(.+)$/)
            message = match && match[4]
            message = message.to_s.strip
            command_key = message
            command_key[0] = ''
            command_key = command_key.to_sym

            if line.include?('PING :tmi.twitch.tv')
              puts 'Pinged, responding with PONG'
              send "PONG :tmi.twitch.tv"
            elsif TwitchBotCommands::DEV_DEFINED_METHODS.include?(command_key)
              user = match[1]
              logger.info "USER COMMAND: #{user} - #{message}"
              bot_messages = [TwitchBotCommands.try(command_key)].flatten
              bot_messages.each{|bot_message| send "PRIVMSG ##{channel_name} :#{bot_message}" }
            elsif custom_command = CustomCommand.where('command = ?', command_key.to_s).last
              logger.info "USER COMMAND: #{user} - #{message}"
              send "PRIVMSG ##{channel_name} :#{custom_command.response}"
            end

            logger.info "> #{line}"
          end
        end
      end
    end

    def stop
      @running = false
    end
  end
end
