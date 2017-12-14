class HomeController < ApplicationController
  def index
    @channel_bots = ChannelBot.where(channel_id: current_channel.id)
  end
end
