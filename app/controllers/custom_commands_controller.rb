class CustomCommandsController < ApplicationController
  def index
    @custom_commands = (
    CustomCommand.select('custom_commands.*,
                          COALESCE(command_permissions.permission_id, 0) AS command_permission_id')
                 .where('custom_commands.channel_id = ?', current_channel.id)
                 .joins('LEFT JOIN command_permissions ON custom_commands.id = command_permissions.command_id')
                 .order('LOWER(command) ASC')
    )
  end

  def create
    @custom_command = CustomCommand.new(custom_command_params)
    if @custom_command.save
    else
    end
    redirect_to custom_commands_path
  end

  def update
    @custom_command = CustomCommand.find(params[:id])
    if @custom_command.update_attributes(custom_command_params)
    else
    end
    redirect_to custom_commands_path
  end

  def destroy
    CustomCommand.find(params[:id]).destroy
    redirect_to custom_commands_path
  end

  private

  def custom_command_params
    params.require(:custom_command).permit(:command, :response, :channel_id, :permission_id)
  end
end
