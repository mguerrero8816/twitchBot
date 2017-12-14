class CommandPermission < ApplicationRecord
  PERMISSIONS = [ 'Admins', 'All' ].freeze
  validates_uniqueness_of :custom_command_id, scope: :channel_id

  def permission_name
    PERMISSIONS[permission_id]
  end
end
