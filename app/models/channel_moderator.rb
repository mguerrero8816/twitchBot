class ChannelModerator < ApplicationRecord
  validates_uniqueness_of :moderator_name, scope: %i[channel_bot_id], case_sensitive: false
end
