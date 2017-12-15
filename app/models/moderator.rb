class Moderator < ApplicationRecord
  validates_uniqueness_of :name, scope: %i[channel_id], case_sensitive: false
end
