class CommandsController < ApplicationController
  def index
    command_names = TwitchBotCommands::DEV_DEFINED_METHODS
    command_sql_data = CommandPermission.where('command_permissions.channel_id = ? AND command_permissions.command_name IN (?) AND command_permissions.command_id IS NULL', current_channel.id, command_names)
    commands_data = {}
    command_sql_data.each do |sql_data|
      commands_data[sql_data.command_name] = sql_data
    end
    Struct.new('BotCommand', :id, :name, :permission_id, :channel_id)
    @commands = []
    command_names.each do |command_name|
      sql_data = commands_data[command_name]
      bot_command = Struct::BotCommand.new(sql_data.try(:id), command_name, sql_data.try(:permission_id), sql_data.try(:channel_id))
      @commands << bot_command
    end
  end
end
