class TwitchBotsController < ApplicationController
  def connect
    ChannelBot.find(params[:bot_id]).connect
    redirect_to root_path
  end

  def disconnect
    ChannelBot.find(params[:bot_id]).disconnect
    redirect_to root_path
  end
end
