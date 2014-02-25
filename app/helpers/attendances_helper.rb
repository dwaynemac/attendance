module AttendancesHelper

  def timeslot_description(timeslot)
    "'#{timeslot.name}' #{timeslot.start_at.hour}:#{minutes(timeslot.start_at)}-#{timeslot.end_at.hour}:#{minutes(timeslot.end_at)} (#{timeslot.padma_uid})"
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
