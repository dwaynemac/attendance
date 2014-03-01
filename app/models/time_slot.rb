class TimeSlot < ActiveRecord::Base
  belongs_to :account
  
  has_many :contact_time_slots
  has_many :contacts, through: :contact_time_slots

  has_many :trial_lessons, dependent: :nullify

  validates :account,  :presence => true
  validates :name,  :presence => true
  validates_time :end_at, :after => :start_at

  attr_accessible :padma_uid, :name, :start_at, :end_at, :padma_contacts, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :cultural_activity, :external_id

  before_create :set_defaults

  def recurrent_contacts
    AttendanceContact.joins(:attendance).joins(:contact).where('contacts.padma_status' => 'student').where('attendances.time_slot_id' => self.id).group('contacts.padma_id, contacts.name').select("contacts.name as first_name, '' as last_name, contacts.padma_id as _id, count(*) as count").order('count desc').limit(15)
  end

  # WARNING this method persists it's changes automatically.
  def padma_contacts= padma_contacts
    if self.persisted?
      self.contact_time_slots.delete_all
      padma_contacts.each do |padma_contact_id|
        contact = Contact.get_by_padma_id(padma_contact_id,self.account_id)
        self.contact_time_slots.create(contact_id: contact.id)
      end
    end
  end

  private

  def set_defaults
    if self.cultural_activity.nil?
      self.cultural_activity = false
    end

    # return true to avoid this filter breaking the callback queue.
    return true
  end
end
