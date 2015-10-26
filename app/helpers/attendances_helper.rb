module AttendancesHelper

  def future_lesson?(date,time_slot)
	  lesson_time = Time.zone.local(date.year, date.month, date.day, time_slot.start_at.hour, time_slot.start_at.min) >= Time.zone.now
  end

  def keep_params
    params.select{|k,v| k.in?(%W(days_to days_from only_pending username))}
  end

  def keep_params_hidden_tag
    hidden_field_tag :redirect_back_w_params, @back_w_params.to_json
  end

  def render_time_slot?(time_slot,date,att, only_pending)
    (att.present? && !only_pending) || (att.blank? && time_slot.send(Date::DAYNAMES[date.wday].downcase.to_sym) )
  end

  def timeslot_description(timeslot, attendance=nil)
	  "#{timeslot_period(timeslot)} (#{attendance.present? ? attendance.username : timeslot.padma_uid})"
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
