class Attendance < ActiveRecord::Base
  belongs_to :account
  belongs_to :time_slot

  has_many :attendance_contacts, inverse_of: :attendance
  has_many :contacts, through: :attendance_contacts

  validates :account, presence: true
  validates :time_slot, presence: true
  validates :attendance_on, presence: true
  validates_date :attendance_on, on_or_before: :today

  attr_accessor :padma_contacts

  attr_accessible :account_id, :time_slot_id, :attendance_on, :padma_contacts

  accepts_nested_attributes_for :attendance_contacts

  def trial_lessons
    TrialLesson.where(time_slot_id: self.time_slot_id, trial_on: self.attendance_on)
  end

  def padma_contacts= padma_contacts
  	contact_ids = []
  	padma_contacts.each do |padma_contact_id|
    	unless contact = Contact.find_by_padma_id(padma_contact_id)
        padma_contact = PadmaContact.find(padma_contact_id, select: [:first_name, :last_name, :local_status], :username => time_slot.padma_uid,  :account_name => time_slot.account.name)
        contact = Contact.create(padma_id: padma_contact_id, account_id: time_slot.account.id, name: "#{padma_contact.first_name} #{padma_contact.last_name}", padma_status: padma_contact.local_status)
      end
    	contact_ids << contact.id
    end
    self.contact_ids = contact_ids
  end
end
