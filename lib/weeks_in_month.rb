module WeeksInMonth
  WEEK_NUMBER_FORMAT = '%W'

  # Returns the first day of month.
  # If invoked without any arguments, this would return the
  # first day of current month
  def first_day_of_month(date_time=Time.now)
    date_time.beginning_of_month
  end
  
  # Returns the last day of month.
  # If invoked without any arguments, this would return the
  # last day of current month
  def last_day_of_month(date_time=Time.now)
    date_time.end_of_month
  end
  
  # Returns the week number in the year in which the specified date_time lies.
  # If invoked without any arguments, this would return the
  # the week number in the current year
  def week_number(date_time=Time.now)
    date_time.strftime(WEEK_NUMBER_FORMAT).to_i
  end
  
  # Returns the number of weeks in the month in which the specified date_time lies.
  # If invoked without any arguments, this would return the
  # the number of weeks in the current month
  def weeks_in_month(date_time=Time.now)
    week_number(last_day_of_month(date_time)) - week_number(first_day_of_month(date_time))  + 1
  end 
end