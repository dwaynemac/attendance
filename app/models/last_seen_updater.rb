class LastSeenUpdater < ActiveRecord::Base
  def self.update_account(account_name)
    st = students(account_name)
    if st.blank?
      Rails.logger.debug "Could not find students with account name: #{account_name}"
    else
      st.each do |student|
        attendance = last_attendance_for_contact(student)
        student.padma_contact.update({contact: {last_seen_at: attendance.attendance_on},
                                      ignore_validation: true,
                                      username: attendance.time_slot.padma_uid,
                                      account_name: attendance.account.name})
      end
    end
  end

  private
  def self.students(account_name)
    CrmLegacyContact.paginate(where: {local_status: :student},
                          account_name: account_name,
                          per_page: 1000)
  end

  def self.last_attendance_for_contact(contact)
    Attendance.joins(:contacts).where("contacts.id" => contact.id).order(attendance_on: :desc).first
  end
end
