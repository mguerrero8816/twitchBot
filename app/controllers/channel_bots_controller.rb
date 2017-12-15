class ChannelBotsController < ApplicationController
  def index
    @channel_bots = ChannelBot.where(channel_id: current_channel.id)
  end

  def show
    @channel_bot = ChannelBot.find(params[:id])
    @moderators = Moderator.where(channel_id: params[:id])
    @command_permissions = CommandPermission.select('command_permissions.*, custom_commands.command AS command_name').where(channel_id: params[:id]).joins('LEFT JOIN custom_commands ON command_permissions.command_id = custom_commands.id')
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

  def add_moderator
    Moderator.create(channel_bot_id: params[:id], name: params[:name])
    redirect_to channel_bot_path(params[:id])
  end

  def add_command_permission
    CommandPermission.create(channel_bot_id: params[:id], custom_command_id: params[:custom_command_id], permission_id: params[:permission_id] )
    redirect_to channel_bot_path(params[:id])
  end

  def destroy_moderator
    Moderator.find(params[:moderator_id]).destroy
    redirect_to channel_bot_path(params[:id])
  end

  def destroy_command_permission
    CommandPermission.find(params[:custom_command_id]).destroy
    redirect_to channel_bot_path(params[:id])
  end

  private

  def channel_bot_params
    params.require(:channel_bot).permit(:live_status_id, :intended_status_id, :channel_id, :bot_name)
  end
end
