class ChannelCommandPermission < ApplicationRecord
  PERMISSIONS = [ 'Admins', 'All' ].freeze
  validates_uniqueness_of :custom_command_id, scope: :channel_bot_id


  def permission_name
    PERMISSIONS[permission_id]
  end
end
