class CustomCommand < ApplicationRecord
  validates :command, format: { with: /\A[A-Za-z0-9]+\z/ }, uniqueness: { case_sensitive: false, scope: :channel_id }
  validates :command, :response, :channel_id, presence: true
  attr_accessor :permission_id, :repeater_start, :repeater_cycle
  after_commit :update_permission, :update_repeater

  private

  def update_permission
    if !permission_id.nil?
      current_permission = CommandPermission.where(command_id: id).first || CommandPermission.new(command_id: id, channel_id: channel_id)
      current_permission.permission_id = permission_id
      current_permission.save
    end
  end

  def update_repeater
    current_repeater = CommandRepeater.where(command_id: id).first || CommandRepeater.new(command_id: id, channel_id: channel_id)
    current_repeater.start_at = repeater_start
    current_repeater.cycle_seconds = repeater_cycle
    current_repeater.save
  end
end
