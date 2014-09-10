require 'csv'
require 'open-uri'

class AttendanceImport < Import

  def valid_headers
    %W(attendance_on time_slot_external_id contact_external_id)
  end

  def handle_row(row,row_i)
    a, mess = build_attendance_contact(row)
    a.skip_update_last_seen_at = true unless a.nil?
    
    if a && a.save
      ImportedId.new(value: a.id)
    else
      if a
        message = a.errors.messages.map{|attr,err_array| "#{attr}: #{err_array.join(' and ')}" }.join(' AND ')
      else
        message = mess
      end
      FailedRow.new(value: row_i,
                    message: message
                   )
    end
  end

  private

  # @return [AttendanceContact/nil]
  def build_attendance_contact(row)
    attendance_on = value_for(row,'attendance_on')
    
    external_id = value_for(row,'time_slot_external_id')
    
    # fail
    return nil,"didn't find external_id in row" unless !external_id.nil?

    time_slot_id = TimeSlot.where(external_id: external_id).pluck(:id).first

    attendance = Attendance.find_or_create_by(attendance_on: attendance_on,
                                              time_slot_id: time_slot_id,
                                              account_id: self.account.id)
    if attendance.nil?
      # fail
      return nil, "didn't find and couldnt create attendance"
    else
      cid = value_for(row, 'contact_external_id')
      contact = map_contact(cid)
      if contact.nil?
        # fail
        return nil, "didn't find contact"
      else
        attendance.attendance_contacts.new(contact_id: contact.id,
                                           attendance_id: attendance.id)
      end
    end
  end

end
