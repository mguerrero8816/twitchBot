require 'socket'
require 'logger'

module TwitchConnector
  TWITCH_USER = SECRETS[Rails.env]['twitch_bot']['user']
  TWITCH_PASS = SECRETS[Rails.env]['twitch_bot']['pass']
  TWITCH_SERVER = 'irc.chat.twitch.tv'
  TWITCH_PORT = 6667
  TWITCH_CHANNEL = SECRETS[Rails.env]['twitch_bot']['user']
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

    def run(thread_name)
      # terminate existing threads with same name
      TwitchConnector.disconnect(thread_name)

      logger.info 'Preparing to connect...'

      @socket = TCPSocket.new('irc.chat.twitch.tv', 6667)
      @running = true

      socket.puts("PASS #{TWITCH_PASS}")
      socket.puts("NICK #{TWITCH_USER}")

      logger.info 'Connected...'

      Thread.start do
        Thread.current["name"] = thread_name
        while (running) do
          ready = IO.select([socket])

          ready[0].each do |s|
            line    = s.gets
            match   = line.match(/^:(.+)!(.+) PRIVMSG #(.+) :(.+)$/)
            message = match && match[4]

            if message =~ /^!hello/
              user = match[1]
              logger.info "USER COMMAND: #{user} - !hello"
              send "PRIVMSG ##{TWITCH_CHANNEL} :Hello, #{user} from #{TWITCH_BOT_NAME}"
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

  def self.connect(channel=TWITCH_CHANNEL)
    bot = Twitch.new
    bot.run(channel)
    bot.send("JOIN \##{channel}")

    # terminal commands. (unable to run in server)
    # while (bot.running) do
    #   command = gets.chomp
    #
    #   if command == 'quit'
    #     bot.stop
    #   else
    #     bot.send(command)
    #   end
    # end
  end

  def self.disconnect(thread_name=TWITCH_CHANNEL)
    twitch_bot_threads = Thread.list.select{|thread| thread[:name] == thread_name }
    twitch_bot_threads.each{|thread| thread.kill}
  end
end
