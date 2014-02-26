module AttendancesHelper

  def timeslot_description(timeslot)
    "#{timeslot_period(timeslot)} (#{timeslot.padma_uid})"
  end

  def timeslot_period(timeslot)
    "#{timeslot.start_at.hour}:#{minutes(timeslot.start_at)}-#{timeslot.end_at.hour}:#{minutes(timeslot.end_at)}"
  end

  private

  def minutes(datetime)
    m = datetime.min
    if m < 10
      "0#{m}"
    else
      m
    end
  end

end
