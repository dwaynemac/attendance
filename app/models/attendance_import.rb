require 'csv'
require 'open-uri'

class AttendanceImport < Import

  def valid_headers
    %W(attendance_on contact_external_id time_slot_external_id)
  end

  def process_CSV
    return unless self.status == :ready

    file_handle = open(self.csv_file.file.path)
    unless file_handle.nil?
      row_i = 1 # start at 1 because first row is skipped
      CSV.foreach(file_handle, encoding:"UTF-8:UTF-8", headers: :first_row) do |row|
        a = build_attendance_contact(row)

        if a && a.save
          self.imported_ids << a.id
        else
          self.failed_rows << row_i
        end

        row_i +=1 
      end
    end

    self.status = :finished
    self.save
  end

  private

  # @return [AttendanceContact/nil]
  def build_attendance_contact(row)
    attendance_on = value_for(row,'attendance_on')
    
    external_id = value_for(row,'time_slot_external_id')
    time_slot_id = TimeSlot.where(external_id: external_id).pluck(:id).first

    attendance = Attendance.find_or_create_by(attendance_on: attendance_on,
                                              time_slot_id: time_slot_id,
                                              account_id: self.account.id)
    unless attendance.nil?
      contact = map_contact(row)
      if contact
        attendance.attendance_contacts.new(contact_id: contact.id,
                                           attendance_id: attendance.id)
      else
        # fail -- didn't find contact
        nil
      end
    else
      # fail -- didn't find and couldnt create attendance
      nil
    end
  end

  # @return [Contact]
  def map_contact(row)
    external_id = value_for(row, 'contact_external_id')
    c = PadmaContact.find_by_kshema_id(external_id)
    Contact.get_by_padma_id(c.id,self.account.id, c) if c
  end
end
