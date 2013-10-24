# header nil is used to ignore a column
class TimeSlotImport < Import

  def valid_headers
    %W(
      name
      start_at
      end_at
      monday
      tuesday
      wednesday
      thursday
      friday
      saturday
      sunday
      cultural_activity
      observations
    )
  end

  def process_CSV

  end


end
