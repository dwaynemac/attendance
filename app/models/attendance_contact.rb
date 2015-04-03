class AttendanceContact < ActiveRecord::Base
  belongs_to :contact
  belongs_to :attendance, inverse_of: :attendance_contacts

  attr_accessible :contact_id, :attendance_id
  attr_accessor :skip_update_last_seen_at #default nil

  validates :contact, presence: true
  validates :attendance, presence: true

  after_create :queue_set_last_seen_at_on_contacts

  def set_last_seen_at_on_contacts
  	last_seen_at = DateTime.new(attendance.attendance_on.year,
                                attendance.attendance_on.month,
                                attendance.attendance_on.day,
                                attendance.time_slot.start_at.hour,
                                attendance.time_slot.start_at.min)
    if contact.padma_contact
      padma_last_seen_at = contact.padma_contact.last_seen_at
      if padma_last_seen_at.blank? || last_seen_at > padma_last_seen_at
        contact.padma_contact.update({contact: {last_seen_at: last_seen_at},
                                      ignore_validation: true,
                                      username: attendance.time_slot.padma_uid,
                                      account_name: attendance.account.name})
      end
    else
      Rails.logger.info "attendance #{attendance.id} couldnt update last_seen_at for contact #{contact.id}"
      # raise exception for delayed_job to retry later
      raise "attendance #{attendance.id} couldnt update last_seen_at for contact #{contact.id}"
    end
  end

  private


  def queue_set_last_seen_at_on_contacts
    return if skip_update_last_seen_at

    self.delay.set_last_seen_at_on_contacts
  end

end
