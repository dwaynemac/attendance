require 'csv'
require 'open-uri'

class AttendanceImport < Import

  def valid_headers
    %W(attendance_on time_slot_external_id contact_external_id)
  end

  def handle_row(row)
    a = build_attendance_contact(row)
    
    if a && a.save
      a.id
    else
      nil
    end
  end

  private

  # @return [AttendanceContact/nil]
  def build_attendance_contact(row)
    attendance_on = value_for(row,'attendance_on')
    
    external_id = value_for(row,'time_slot_external_id')
    
    # fail -- didn't find external_id in row
    return nil unless !external_id.nil?

    time_slot_id = TimeSlot.where(external_id: external_id).pluck(:id).first

    attendance = Attendance.find_or_create_by(attendance_on: attendance_on,
                                              time_slot_id: time_slot_id,
                                              account_id: self.account.id)
    if attendance.nil?
      # fail -- didn't find and couldnt create attendance
      nil
    else
      contact = map_contact(row)
      if contact.nil?
        # fail -- didn't find contact
        nil
      else
        attendance.attendance_contacts.new(contact_id: contact.id,
                                           attendance_id: attendance.id)
      end
    end
  end

  # @return [Contact]
  def map_contact(row)
    external_id = value_for(row, 'contact_external_id')
    c = PadmaContact.find_by_kshema_id(external_id)
    Contact.get_by_padma_id(c.id,self.account.id, c) if c
  end
end
