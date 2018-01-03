class CommandsController < ApplicationController
  def index
    command_names = TwitchBotCommands.methods(false)
    command_settings = (
      CommandPermission.select('command_permissions.command_name AS command_name,
                                COALESCE(command_permissions.id, 0) AS command_permission_id,
                                COALESCE(command_permissions.permission_id, 0) AS permission_id,
                                COALESCE(command_repeaters.id, 0) AS command_repeater_id,
                                COALESCE(command_repeaters.status_id, 0) AS repeater_status_id,
                                command_repeaters.cycle_seconds AS repeater_cycle_seconds,
                                command_repeaters.start_at AS repeater_start_at')
                       .joins('LEFT JOIN command_repeaters ON command_permissions.command_name = command_repeaters.command_name AND command_permissions.channel_id = command_repeaters.channel_id')
                       .where('command_permissions.channel_id = ? AND command_permissions.command_name IN (?) AND command_permissions.command_id IS NULL', current_channel.id, command_names)
    )
    commands_data = {}
    command_settings.each do |command_setting|
      commands_data[command_setting.command_name.to_sym] = command_setting
    end
    Struct.new('CommandSettings', :id, :command_permission_id, :name, :permission_id, :channel_id, :command_repeater_id, :repeater_status_id, :repeater_cycle_seconds, :repeater_start_at)
    @commands = []
    command_names.each_with_index do |command_name, index|
      sql_data = commands_data[command_name]
      bot_command = Struct::CommandSettings.new(index, sql_data.try(:command_permission_id), command_name, sql_data.try(:permission_id), sql_data.try(:channel_id), sql_data.try(:command_repeater_id), sql_data.try(:repeater_status_id), sql_data.try(:repeater_cycle_seconds), sql_data.try(:repeater_start_at))
      @commands << bot_command
    end
  end

  def update
    permission = CommandPermission.where(id: params[:command_permission_id]).last || CommandPermission.create(command_settings_params)
    permission.permission_id = params[:command][:permission_id]
    if permission.save
    else
    end
    repeater = CommandRepeater.where(id: params[:command_repeater_id]).last || CommandRepeater.create(command_settings_params)
    if repeater.update_attributes(command_repeater_params)
    else
    end
    redirect_to commands_path
  end

  private

  def command_settings_params
    { command_name: params[:command][:name], channel_id: params[:command][:channel_id] }
  end

  def command_repeater_params
    params[:command][:command_repeater_attributes][:start_at] = date_from_js_date_picker(params[:command][:command_repeater_attributes], :start_at)
    params[:command].require(:command_repeater_attributes).permit(:status_id, :cycle_seconds, :start_at)
  end
end
