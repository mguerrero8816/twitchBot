class ChannelBotsController < ApplicationController
  def index
    @channel_bots = ChannelBot.all
  end

  def new
    @channel_bot = ChannelBot.new
  end

  def create
    @channel_bot = ChannelBot.new(channel_bot_params)
    if @channel_bot.save
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    @channel_bot = ChannelBot.find(params[:id])
  end

  def update
    @channel_bot = ChannelBot.find(params[:id])
    if @channel_bot.update_attributes(channel_bot_params)
      redirect_to root_path
    else
      render :edit
    end
  end

  def destroy
    ChannelBot.find(params[:id]).destroy
    redirect_to root_path
  end

  private

  def channel_bot_params
    params.require(:channel_bot).permit(:live_status_id, :intended_status_id, :channel_name, :bot_name)
  end
end
