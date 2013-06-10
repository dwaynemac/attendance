class TrialLesson < ActiveRecord::Base
  belongs_to :account
  belongs_to :contact
  belongs_to :time_slot

  validates :account, presence: true
  validates :contact, presence: true
  validates :time_slot, presence: true
  validates :padma_uid, presence: true
  validates :trial_on, presence: true

  attr_accessor :padma_contact_id

  attr_accessible :trial_on, :time_slot_id, :padma_uid, :padma_contact_id, :assisted

  after_create :create_activity

  def padma_contact_id= padma_contact_id
  	self.contact = Contact.find_or_create_by_padma_id(padma_contact_id, account_id: self.time_slot.account.id)
  end

  def padma_contact_id
    self.contact.try(:padma_id)
  end

  def create_activity
      # Send notification to activities
    if !self.contact_id.nil?
      a = ActivityStream::Activity.new(target_id: self.contact.padma_id, target_type: 'Contact',
                                 object_id: self.id, object_type: 'TrialLesson',
                                 generator: ActivityStream::LOCAL_APP_NAME,
                                 content: "Trial Lesson created",
                                 public: false,
                                 username: self.padma_uid,
                                 account_name: self.account.name,
                                 created_at: Time.zone.now.to_s,
                                 updated_at: Time.zone.now.to_s )
      a.create(username: self.padma_uid, account_name: self.account.name)
    end
  end
end
