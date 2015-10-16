module AttendancesHelper

  def render_time_slot?(time_slot,date,att, only_pending)
    (att.present? && !only_pending) || (att.blank? && time_slot.send(Date::DAYNAMES[date.wday].downcase.to_sym) )
  end

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
