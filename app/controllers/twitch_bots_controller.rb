class TwitchBotsController < ApplicationController
  def connect
    TwitchConnector.connect(params[:channel_name])
    redirect_to root_path
  end

  def disconnect
    TwitchConnector.disconnect(params[:channel_name])
    redirect_to root_path
  end
end
