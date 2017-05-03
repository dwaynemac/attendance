module TimeSlotsHelper
  
  def already_selected_day_name
    selected_day = []
    Date::DAYNAMES.map{|day| day.downcase}.each do |day_name|
      selected_day << day_name.capitalize if @time_slot[day_name]
    end  
    selected_day
  end

  def showSchedule( time_slot )
    days = I18n.t('date.abbr_day_names')
    ret = []
    [time_slot.sunday,time_slot.monday,time_slot.tuesday,time_slot.wednesday,time_slot.thursday,time_slot.friday,time_slot.saturday,time_slot.sunday].each_with_index do |day,i|
      if day
        ret << days[i]
      end
    end
    ret.compact.join(',')
  end
  
  def crm_contacts_list_url( time_slot )
    columns_query = %W(full_name local_teacher level time_since_first_enrollment last_seen_at membership_name membership_value).map{|col| "contact_search[chosen_columns][]=#{col}" }.join('&')
    "#{APP_CONFIG['crm-url']}/contacts?contact_search[linked_to_time_slot_ids][]=#{time_slot.id}&#{columns_query}"
  end

end
