require 'socket'
require 'logger'

module TwitchConnector
  TWITCH_USER = SECRETS[Rails.env]['twitch_bot']['user']
  TWITCH_PASS = SECRETS[Rails.env]['twitch_bot']['pass']
  TWITCH_SERVER = 'irc.chat.twitch.tv'
  TWITCH_PORT = 6667
  TWITCH_BOT_NAME = 'Mikebot'

  Thread.abort_on_exception = true

  class Twitch
    attr_reader :logger, :running, :socket

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

    def run(channel_name)
      # terminate existing threads with same name
      TwitchConnector.disconnect(channel_name)

      logger.info 'Preparing to connect...'

      @socket = TCPSocket.new('irc.chat.twitch.tv', 6667)
      @running = true

      socket.puts("PASS #{TWITCH_PASS}")
      socket.puts("NICK #{TWITCH_USER}")

      logger.info 'Connected...'

      Thread.start do
        Thread.current["channel_name"] = channel_name
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

            if TwitchBotCommands::DEV_DEFINED_METHODS.include?(command_key)
              user = match[1]
              logger.info "USER COMMAND: #{user} - #{message}"
              bot_message = TwitchBotCommands.try(command_key)
              # send "PRIVMSG ##{channel_name} :Hello, #{user} from #{TWITCH_BOT_NAME}"
              send "PRIVMSG ##{channel_name} :#{bot_message}"
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

  def self.connect(channel_name)
    if !channel_name.blank?
      bot = Twitch.new
      bot.run(channel_name)
      bot.send("JOIN ##{channel_name}")
    end
  end

  def self.disconnect(channel_name)
    if !channel_name.blank?
      twitch_bot_threads = Thread.list.select{|thread| thread[:channel_name] == channel_name }
      twitch_bot_threads.each{|thread| thread.kill}
    end
  end
end
