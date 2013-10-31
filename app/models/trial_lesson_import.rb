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
    new_time_slot = self.account.trial_lessons.new

    ts_external_id = value_for(row,'time_slot_external_id')
    if ts_external_id 
      time_slot_id = TimeSlot.where(external_id: ts_external_id).pluck(:id).first

      contact_exid = value_for(row,'contact_external_id')
      contact = map_contact(contact_exid) if contact_exid
      if contact
        new_time_slot.contact_id = contact.id 
        new_time_slot.time_slot_id = time_slot_id

        (valid_headers-%W(contact_external_id time_slot_external_id)).each do |header|
          new_time_slot.send("#{header}=",value_for(row,header))
        end
      
        if new_time_slot.save!
          ImportedId.new value: new_time_slot.id
        else
          FailedRow.new(value: row_i,
                        message: new_time_slot.errors.messages.map{|attr,err_array| "#{attr}: #{err_array.join(' and ')}" }.join(' AND '))
        end

      else
        FailedRow.new value: row_i, message: "contact not found"
      end
    else
      FailedRow.new value: row_i, message: "no timeslot specified"
    end
  end


end
