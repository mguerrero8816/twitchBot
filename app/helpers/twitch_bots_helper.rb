module TwitchBotsHelper
  def bot_status(thread_name)
    twitch_bot_threads = Thread.list.select{|thread| thread[:channel_name] == thread_name && thread.status == 'sleep' }
    bot_active = twitch_bot_threads.count > 0
    bot_active ? 'Active' : 'Inactive'
  end
end
