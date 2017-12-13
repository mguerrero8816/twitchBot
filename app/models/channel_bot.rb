class ChannelBot < ApplicationRecord
  include TwitchConnector
  after_initialize :set_defaults
  validates :bot_name, :channel_id, :live_status_id, :intended_status_id, presence: true
  validates :live_status_id, :intended_status_id, numericality: { less_than: 2 }
  STATUSES = [ 'Inactive', 'Active' ]

  def live_status
    STATUSES[live_status_id]
  end

  def intended_status
    STATUSES[intended_status_id]
  end

  def channel_name
    Channel.find(channel_id).name
  end

  private

  def set_defaults
    self.live_status_id ||= 0
    self.intended_status_id ||= 0
  end
end
