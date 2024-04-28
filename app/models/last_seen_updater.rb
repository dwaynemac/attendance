class LastSeenUpdater < ActiveRecord::Base
  def self.update_account(account_name)
    st = students(account_name)
    if st.blank?
      Rails.logger.debug "Could not find students with account name: #{account_name}"
    else
      account = Account.find_by(name: account_name)
      if account.padma.try(:attendance_enabled)
        st.each do |student|
          if (attendance = last_attendance_for_contact(student, account))
            student.update({
              contact: {last_seen_at: attendance.attendance_on},
              ignore_validation: true,
              async: true,
              username: attendance.time_slot.nil? ? account.usernames.first : attendance.time_slot.padma_uid,
              account_name: attendance.account.name
            })
          end
        end
      end
    end
  end

  private
  def self.students(account_name)
    CrmLegacyContact.paginate(where: {local_status: :student},
                          account_name: account_name,
                          per_page: 1000)
  end

  def self.last_attendance_for_contact(contact, account)
    Attendance.joins(:contacts).where("contacts.padma_id" => contact.id, account_id: account.id).order(attendance_on: :desc).first
  end
end
