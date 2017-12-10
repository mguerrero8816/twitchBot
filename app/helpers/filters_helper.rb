module FiltersHelper
  def custom_command_options_for_select
    custom_commands = CustomCommand.order('command')
    options_for_select(custom_commands.map{|command| ["!#{command.command}", command.id]})
  end

  def permission_options_for_select
    permissions = ChannelCommandPermission::PERMISSIONS
    options_for_select(permissions.map.with_index{|permission, index| [permission, index]})
  end
end
