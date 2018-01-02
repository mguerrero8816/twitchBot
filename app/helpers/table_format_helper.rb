module TableFormatHelper
  def standard_table_date(date)
    date ? date.strftime('%m/%d/%y') : '-'
  end

  def standard_table_time(time)
    time ? time.strftime('%I:%M%P') : '-'
  end

  def standard_table_text(string)
    string.blank? ? '-' : string
  end
end
