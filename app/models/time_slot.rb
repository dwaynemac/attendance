class TimeSlot < ActiveRecord::Base
  belongs_to :account
  
  has_many :contact_time_slots
  has_many :contacts, through: :contact_time_slots

  validates :account,  :presence => true
  validates :name,  :presence => true
  validates_time :end_at, :after => :start_at

  attr_accessible :padma_uid, :name, :start_at, :end_at, :padma_contacts, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :cultural_activity, :external_id

  before_create :set_defaults

  def recurrent_contacts
    #TODO: Aprovechar el cache de name y no ir a buscar la lista a contacts.
  	padma_contact_ids = AttendanceContact.joins(:attendance).joins(:contact).where('attendances.time_slot_id' => self.id).group('contacts.padma_id').count().keys
  	padma_contact_ids.concat(contacts.collect(&:padma_id))
  	PadmaContact.paginate(ids: padma_contact_ids, select: [:first_name, :last_name], per_page: padma_contact_ids.size)
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
