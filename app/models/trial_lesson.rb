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

  after_create :create_activity, :broadcast_create

  def padma_contact_id= padma_contact_id
  	self.contact = Contact.find_or_create_by_padma_id(padma_contact_id, account_id: self.account_id)
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
                                 content: I18n.t('trial_lesson.activity_content.create'),
                                 public: false,
                                 username: self.padma_uid,
                                 account_name: self.account.name,
                                 created_at: Time.zone.now.to_s,
                                 updated_at: Time.zone.now.to_s )
      a.create(username: self.padma_uid, account_name: self.account.name)
    end
  end

  def broadcast_create
    # Send notification using the messaging system
    if Messaging::Client.post_message('trial_lesson',self.as_json_for_messaging)
      # self.update_attribute :posted_to_messaging, true
    end
  end  

  def as_json_for_messaging
    json = as_json
    json["contact_id"] = contact.padma_id
    json["recipient_email"] = contact.padma_contact.email
    json["username"] = padma_uid
    json["account_name"] = account.name
    json
  end  
end
