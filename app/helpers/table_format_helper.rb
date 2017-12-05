module TableFormatHelper
  def standard_table_date(date)
    date.strftime('%m/%d/%y') if date
  end

  def standard_table_time(time)
    time.strftime('%I:%M%P') if time
  end
end
