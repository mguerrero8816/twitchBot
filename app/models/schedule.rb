class Schedule < ApplicationRecord
  attr_accessor :start_at_date, :start_at_time

  def start_at_date
    start_at
    Date.new(start_at.year, start_at.month, start_at.day)
  end

  def start_at_time
    start_at
  end
end
