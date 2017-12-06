class CustomCommandsController < ApplicationController
  def index
    @custom_commands = CustomCommand.order('LOWER(command) ASC')
  end

  def new
    @custom_command = CustomCommand.new
  end

  def create
    @custom_command = CustomCommand.new(custom_command_params)
    if @custom_command.save
      redirect_to custom_commands_path
    else
      render :new
    end
  end

  def edit
    @custom_command = CustomCommand.find(params[:id])
  end

  def update
    @custom_command = CustomCommand.find(params[:id])
    if @custom_command.update_attributes(custom_command_params)
      redirect_to custom_commands_path
    else
      render :edit
    end
  end

  def destroy
    CustomCommand.find(params[:id]).destroy
    redirect_to custom_commands_path
  end

  private

  def custom_command_params
    params.require(:custom_command).permit(:command, :response)
  end
end
