module TableFormatHelper
  def standard_table_date(date)
    date.strftime('%m/%d/%y') if date
  end
end
