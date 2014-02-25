module AttendancesHelper

  def timeslot_description(timeslot)
    "'#{timeslot.name}' #{timeslot.start_at.hour}:#{timeslot.start_at.min}-#{timeslot.end_at.hour}:#{timeslot.end_at.min} (#{timeslot.padma_uid})"
  end

end
