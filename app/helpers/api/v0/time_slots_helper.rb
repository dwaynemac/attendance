module Api::V0::TimeSlotsHelper
    
  # maps time_slots collection to JSON
  # option :include_recurrent_contacts will add recurrent_contacts array of IDS
  # option :
  # 
  def api_json_for_collection(time_slots, options={})
    time_slots.map do |t|
      api_json(t,options)
    end
  end
  
  def api_json(time_slot, options={})
    ret = {
      id: time_slot.id,
      name: time_slot.name,
      description: time_slot.description,
      start_at: time_slot.start_at.strftime('%H:%M'),
      end_at: time_slot.end_at.strftime('%H:%M'),
      schedule: time_slot.unscheduled?? '-' : time_slot.time_slot_days,
      account_name: time_slot.account.try(:name),
      teacher: time_slot.padma_uid,
      contacts: time_slot.contacts.map(&:padma_id)
    }
    if options[:include_recurrent_contacts]
      ret.merge!({recurrent_contacts: time_slot.recurrent_contacts.map(&:padma_id)})
    end
    ret
  end
  
end
