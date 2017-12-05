class TwitchBotsController < ApplicationController

  def connect
    TwitchConnector.connect
    redirect_to root_path
  end

  def disconnect
    TwitchConnector.disconnect
    redirect_to root_path
  end
end
