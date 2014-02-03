require 'csv'
require 'open-uri' # todo do we need this here?

class TrialLessonImport < Import

  # Headers for CSV
  # - assisted: whether the contact assisted to the trial lesson or not.
  # - padma_uid: teacher that marked the trial lesson.
  # - contact_external_id: contact's id at remote service (currenty only kshema)
  # - time_slot_external_id: time_slot's id at remote service (currently only kshema)
  def valid_headers
    %W(
      contact_external_id
      time_slot_external_id
      trial_on
      padma_uid
      assisted
      confirmed
      archived
      absence_reason
    )
  end
  
  # return created id or nil
  def handle_row(row,row_i)
    new_trial_lesson = self.account.trial_lessons.new

    ts_external_id = value_for(row,'time_slot_external_id')
    if ts_external_id 
      time_slot_id = TimeSlot.where(external_id: ts_external_id).pluck(:id).first

      contact_exid = value_for(row,'contact_external_id')
      contact = map_contact(contact_exid) if contact_exid
      if contact
        new_trial_lesson.contact_id = contact.id 
        new_trial_lesson.time_slot_id = time_slot_id

        (valid_headers-%W(contact_external_id time_slot_external_id)).each do |header|
          new_trial_lesson.send("#{header}=",value_for(row,header))
        end
      
        archived = value_for(row, 'archived')
        new_trial_lesson.archived = (archived == "true" ? true : false)
        new_trial_lesson.skip_broadcast = true
        new_trial_lesson.activity_on_trial_time = true
        if new_trial_lesson.save!
          ImportedId.new value: new_trial_lesson.id
        else
          FailedRow.new(value: row_i,
                        message: new_trial_lesson.errors.messages.map{|attr,err_array| "#{attr}: #{err_array.join(' and ')}" }.join(' AND '))
        end

      else
        FailedRow.new value: row_i, message: "contact not found"
      end
    else
      FailedRow.new value: row_i, message: "no timeslot specified"
    end
  end


end
