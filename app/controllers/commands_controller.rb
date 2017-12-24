class CommandsController < ApplicationController
  def index
    command_names = TwitchBotCommands::DEV_DEFINED_METHODS
    command_sql_data = CommandPermission.where('command_permissions.channel_id = ? AND command_permissions.command_name IN (?) AND command_permissions.command_id IS NULL', current_channel.id, command_names)
    commands_data = {}
    command_sql_data.each do |sql_data|
      commands_data[sql_data.command_name.to_sym] = sql_data
    end
    Struct.new('BotCommand', :id, :name, :permission_id, :channel_id)
    @commands = []
    command_names.each do |command_name|
      sql_data = commands_data[command_name]
      bot_command = Struct::BotCommand.new(sql_data.try(:id), command_name, sql_data.try(:permission_id), sql_data.try(:channel_id))
      @commands << bot_command
    end
  end

  def update
    if params[:id] == '0'
      permission = CommandPermission.new(command_name: params[:command][:name], channel_id: params[:command][:channel_id])
    else
      permission = CommandPermission.find(params[:id])
    end
    permission.permission_id = params[:command][:permission_id]
    if permission.save
    else
    end
    redirect_to commands_path
  end
end
