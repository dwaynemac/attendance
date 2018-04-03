module TrialLessonsHelper
  def api_json_for_collection(trials)
    trials.map do |t|
      {
        id: t.id,
        account_name: t.account.try(:name),
        username: t.padma_uid,
        contact_id: t.contact.try(:padma_id),
        trial_on: t.trial_on,
        assisted: t.assisted,
        confirmed: t.confirmed,
        archived: t.archived,
        absence_reason: t.absence_reason
      }
    end
  end
      
  def monday(date)
    date.beginning_of_week(:monday)
  end
  
  def sunday(date)
    date.end_of_week(:monday)
  end
    
end
