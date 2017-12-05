class Schedule < ApplicationRecord
  attr_accessor :start_at_date, :start_at_time

  def start_at_date
    Date.new(start_at.year, start_at.month, start_at.day) if start_at
  end

  def start_at_time
    start_at
  end
end
