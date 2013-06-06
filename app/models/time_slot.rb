class TimeSlot < ActiveRecord::Base
  belongs_to :account
  has_many :contacts
  validates :account,  :presence => true
  validates :name,  :presence => true
  validates_time :end_at, :after => :start_at

  attr_accessible :padma_uid, :name, :start_at, :end_at, :padma_contacts, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :cultural_activity

  def recurrent_contacts
  	padma_contact_ids = AttendanceContact.joins(:attendance).joins(:contact).where('attendances.time_slot_id' => self.id).group('contacts.padma_id').count().keys
  	padma_contact_ids.concat(contacts.collect(&:padma_id))
  	PadmaContact.paginate(ids: padma_contact_ids, per_page: padma_contact_ids.size)
  end

  def padma_contacts= padma_contacts
  	contact_ids = []
  	padma_contacts.each do |padma_contact_id|
    	contact = Contact.find_or_create_by(padma_id: padma_contact_id, account_id: self.account.id)
    	contact_ids << contact.id
    end
    self.contact_ids = contact_ids
  end
end
