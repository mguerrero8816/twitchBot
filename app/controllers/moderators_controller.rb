class ModeratorsController < ApplicationController
  def index
    @moderators = Moderator.where(channel_id: current_channel.id)
  end

  def create
    @moderator = Moderator.new(moderator_params)
    if @moderator.save
    else
    end
    redirect_to moderators_path
  end

  def update
    redirect_to moderators_path
  end

  def destroy
    redirect_to moderators_path
  end

  private

  def moderator_params
    params.require(:moderator).permit(:name, :channel_id)
  end
end
