module Api::V0::TimeSlotsHelper
    
  def api_json_for_collection(time_slots)
    time_slots.map do |t|
      {
        id: t.id,
        name: t.name,
        description: t.description,
        start_at: t.start_at.strftime('%H:%M'),
        end_at: t.end_at.strftime('%H:%M'),
        schedule: t.unscheduled?? '-' : t.time_slot_days,
        account_name: t.account.try(:name),
        teacher: t.padma_uid
      }
    end
  end
  
end
