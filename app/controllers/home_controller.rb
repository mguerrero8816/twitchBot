class HomeController < ApplicationController
  def index
  end

  def start_bot
    @new_bot = TwitchConnector
  end

  def stop_bot
    twitch_bot_threads = Thread.list.select{|thread| thread[:name] == 'twitch_bot_thread' }
    twitch_bot_threads.each{|thread| thread.kill}
  end
end
