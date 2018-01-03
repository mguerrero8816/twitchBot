module TwitchBotCommands
  class << self
    def whatsnext
      responses = []
      next_schedule = Schedule.where('start_at >= ?', Time.zone.now).order('start_at ASC').limit(1).first
      if next_schedule
        local_time = next_schedule.start_at.strftime('%I:%M%P %Z')
        utc_time = next_schedule.start_at.utc.strftime('%I:%M%P %Z')
        responses << "#{local_time} - #{next_schedule.title} - #{next_schedule.description}"
        responses << "#{utc_time} - #{next_schedule.title} - #{next_schedule.description}"
      else
        responses << 'TBD'
      end
      responses
    end
  end
end
