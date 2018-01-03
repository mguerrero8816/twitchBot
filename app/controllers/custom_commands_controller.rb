class CustomCommandsController < ApplicationController
  def index
    @custom_commands = (
    CustomCommand.select('custom_commands.*,
                          COALESCE(command_permissions.permission_id, 0) AS command_permission_id,
                          COALESCE(command_repeaters.status_id, 0) AS repeater_status_id,
                          command_repeaters.cycle_seconds AS repeater_cycle_time,
                          command_repeaters.start_at AS repeater_start_at')
                 .joins('LEFT JOIN command_permissions ON custom_commands.id = command_permissions.command_id')
                 .joins('LEFT JOIN command_repeaters ON custom_commands.id = command_repeaters.command_id')
                 .where('custom_commands.channel_id = ?', current_channel.id)
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
    params[:custom_command][:command_repeater_attributes][:start_at] = date_from_js_date_picker(params[:custom_command][:command_repeater_attributes], :start_at)
    params.require(:custom_command).permit(:command, :response, :channel_id, :permission_id, command_repeater_attributes: [ :status_id, :cycle_seconds, :start_at ])
  end
end
