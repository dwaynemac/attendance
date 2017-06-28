class Attendance < ActiveRecord::Base
  belongs_to :account
  belongs_to :time_slot

  has_many :attendance_contacts, inverse_of: :attendance
  has_many :contacts, through: :attendance_contacts, dependent: :destroy

  validates :account, presence: true
  validates :time_slot, presence: true
  validates :attendance_on, presence: true
  validates :username, presence: true
  validates_date :attendance_on, on_or_before: :today
  validate :only_on_per_day_per_slot

  attr_accessor :padma_contacts

  attr_accessible :account_id, :time_slot_id, :attendance_on, :padma_contacts, :username, :suspended

  accepts_nested_attributes_for :attendance_contacts

  before_validation :set_default_username

  def trial_lessons
    TrialLesson.where(time_slot_id: self.time_slot_id, trial_on: self.attendance_on)
  end

  def padma_contacts= padma_contacts
    return if time_slot.nil?
    contact_ids = []
    padma_contacts.each do |padma_contact_id|
      contact = Contact.get_by_padma_id(padma_contact_id, account_id || time_slot.account_id)
      contact_ids << contact.id
    end
    self.contact_ids = contact_ids
  end

  def set_default_username
    update_attribute(:username, time_slot.padma_uid) unless username.present? or time_slot.blank?
  end
  private

  def only_on_per_day_per_slot
    if Attendance.where(account_id: self.account_id,
                        time_slot_id: self.time_slot_id,
                        attendance_on: self.attendance_on).count > ((self.persisted?)? 1 : 0)
      errors.add(:attendance_on, :already_registered)
    end
  end
end