class TwitchBotsController < ApplicationController

  def connect
    TwitchConnector.connect
  end

  def disconnect
    TwitchConnector.disconnect
  end
end
