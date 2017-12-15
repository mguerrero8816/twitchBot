class ModeratorsController < ApplicationController
  def index
    @moderators = Moderator.where(channel_id: current_channel.id)
  end

  def create
  end

  def update
  end

  def destroy
  end

  private

  def moderator_params
  end
end
