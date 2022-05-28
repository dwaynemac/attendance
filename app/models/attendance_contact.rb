class AttendanceContact < ActiveRecord::Base
  belongs_to :contact
  belongs_to :attendance, inverse_of: :attendance_contacts

  # attr_accessible :contact_id, :attendance_id
  attr_accessor :skip_update_last_seen_at #default nil

  validates :contact_id, presence: true, uniqueness: { scope: :attendance_id }
  validates :attendance, presence: true

  after_save :queue_set_last_seen_at_on_contacts

  def set_last_seen_at_on_contacts
    contact.update_last_seen_at(attendance.account)
  end

  private


  def queue_set_last_seen_at_on_contacts
    return if skip_update_last_seen_at

    LastSeenAtJob.new(
      padma_id: padma_id,
      account_name: attendance.account.name
    ).queue
  end

end
