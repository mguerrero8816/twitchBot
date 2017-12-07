class HomeController < ApplicationController
  def index
    @channel_bots = ChannelBot.all
  end
end
