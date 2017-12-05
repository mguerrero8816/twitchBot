module TwitchBotCommands
  class << self
    def whats_next
      next_schedule = Schedule.where('start_at >= ?', Time.zone.now).order('start_at ASC').limit(1).first
      next_schedule.start_at.to_s
    end
  end

  #keep at end of file
  DEV_DEFINED_METHODS = methods(false)
end
