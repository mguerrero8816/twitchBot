class CustomCommandsController < ApplicationController
  def index
    @custom_commands = CustomCommand.order('LOWER(command) ASC')
  end
end
