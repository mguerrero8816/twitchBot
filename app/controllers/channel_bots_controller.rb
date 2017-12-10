class ChannelBotsController < ApplicationController
  def index
    @channel_bots = ChannelBot.all
  end

  def show
    @channel_bot = ChannelBot.find(params[:id])
    @moderators = ChannelModerator.where(channel_bot_id: params[:id])
    @command_permissions = ChannelCommandPermission.select('channel_command_permissions.*, custom_commands.command AS command_name').where(channel_bot_id: params[:id]).joins('LEFT JOIN custom_commands ON channel_command_permissions.custom_command_id = custom_commands.id')
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
    ChannelModerator.create(channel_bot_id: params[:id], moderator_name: params[:moderator_name])
    redirect_to channel_bot_path(params[:id])
  end

  def add_command_permission
    ChannelCommandPermission.create(channel_bot_id: params[:id], custom_command_id: params[:custom_command_id], permission_id: params[:permission_id] )
    redirect_to channel_bot_path(params[:id])
  end

  def destroy_moderator
    ChannelModerator.find(params[:moderator_id]).destroy
    redirect_to channel_bot_path(params[:id])
  end

  def destroy_command_permission
    ChannelCommandPermission.find(params[:custom_command_id]).destroy
    redirect_to channel_bot_path(params[:id])
  end

  private

  def channel_bot_params
    params.require(:channel_bot).permit(:live_status_id, :intended_status_id, :channel_name, :bot_name)
  end
end
