class ChannelCommandPermission < ApplicationRecord
  PERMISSIONS = [ 'Admins', 'All' ].freeze

  def permission_name
    PERMISSIONS[permission_id]
  end
end
