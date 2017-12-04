require 'socket'
require 'logger'

module TwitchConnector
  # A quick example of a Twitch chat bot in Ruby.
  # No third party libraries. Just Ruby standard lib.
  #
  # See the tutorial video: https://www.youtube.com/watch?v=_FbRcZNdNjQ
  #

  # You can fill in creds here or use environment variables if you choose.

  # TWITCH_CHAT_TOKEN = ENV['TWITCH_CHAT_TOKEN']
  # TWITCH_USER       = ENV['TWITCH_USER']
  TWITCH_USER = 'mikeinthemorning'
  TWITCH_SERVER = 'irc.chat.twitch.tv'
  TWITCH_PORT = 6667
  TWITCH_OAUTH = 'oauth:hd970k3ohrosbvbi9yecr3k8d9fbqu'
  TWITCH_CHAT_TOKEN = 'oauth:hd970k3ohrosbvbi9yecr3k8d9fbqu'

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

    def run
      logger.info 'Preparing to connect...'

      @socket = TCPSocket.new('irc.chat.twitch.tv', 6667)
      @running = true

      socket.puts("PASS #{TWITCH_CHAT_TOKEN}")
      socket.puts("NICK #{TWITCH_USER}")

      logger.info 'Connected...'

      Thread.start do
        Thread.current["name"] = "twitch_bot_thread"
        while (running) do
          ready = IO.select([socket])

          ready[0].each do |s|
            line    = s.gets
            match   = line.match(/^:(.+)!(.+) PRIVMSG #(.+) :(.+)$/)
            message = match && match[4]
            puts message
            puts 'testing stuff'
            puts message.class
            puts message =~ /^!hello/

            if message =~ /^!hello/
              puts 'passing'
              user = match[1]
              logger.info "USER COMMAND: #{user} - !hello"
              send "PRIVMSG ##{TWITCH_USER} :Hello, #{user} from Mailbot!"
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

  if TWITCH_CHAT_TOKEN.empty? || TWITCH_USER.empty?
    puts "You need to fill in your own Twitch credentials!"
    exit(1)
  end

  bot = Twitch.new
  bot.run
  bot.send("JOIN \##{TWITCH_USER}")

  while (bot.running) do
    command = gets.chomp

    if command == 'quit'
      bot.stop
    else
      bot.send(command)
    end
  end

  puts 'Exited.'
end
