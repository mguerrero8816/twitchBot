class CustomCommand < ApplicationRecord
  validates :command, format: { with: /\A[A-Za-z0-9]+\z/ }, uniqueness: { case_sensitive: false, scope: :channel_id }
  validates :command, :response, :channel_id, presence: true
  attr_accessor :permission_id, :command_repeater_attributes
  after_commit :update_permission, :update_repeater

  private

  def update_permission
    if !permission_id.nil?
      current_permission = CommandPermission.where(command_id: id).first || CommandPermission.create(command_id: id, channel_id: channel_id)
      current_permission.permission_id = permission_id
      current_permission.save
    end
  end

  def update_repeater
    current_repeater = CommandRepeater.where(command_id: id).first || CommandRepeater.create(command_id: id, channel_id: channel_id)
    current_repeater.update_attributes(command_repeater_attributes.to_h)
  end
end
