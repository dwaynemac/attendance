class TimeSlot < ActiveRecord::Base
  belongs_to :account
  has_many :contacts
  validates :account,  :presence => true
  validates :name,  :presence => true
  validates_time :end_at, :after => :start_at

  attr_accessible :padma_uid, :name, :start_at, :end_at

  def recurrent_contacts
  	padma_contact_ids = AttendanceContact.joins(:attendance).joins(:contact).where('attendances.time_slot_id' => self.id).group('contacts.padma_id').count().keys
  	padma_contact_ids.concat(contacts.collect(&:padma_id))
  	PadmaContact.paginate(ids: padma_contact_ids, per_page: padma_contact_ids.size)
  end
end
