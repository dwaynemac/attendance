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

  attr_accessible :trial_on, :time_slot_id, :padma_uid, :padma_contact_id, :assisted, :confirmed, :archived, :absence_reason

  after_create :create_activity, :broadcast_create
  after_destroy :destroy_activity

  # Day of trial and Time of trial according to TimeSlot's time
  # @return [DateTime]
  def trial_at
    DateTime.civil(trial_on.year,trial_on.month,trial_on.day,time_slot.start_at.hour,time_slot.start_at.min)
  end

  def padma_contact_id= padma_contact_id
    unless c = Contact.find_by_padma_id_and_account_id(padma_contact_id, self.account_id)
        padma_contact = PadmaContact.find(padma_contact_id, select: [:first_name, :last_name])
        c = Contact.create(padma_id: padma_contact_id, account_id: self.account_id, name: "#{padma_contact.first_name} #{padma_contact.last_name}")
      end
  	self.contact = c
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

  def destroy_activity
    # Send notification to activities
    if !self.contact_id.nil?
      a = ActivityStream::Activity.new(target_id: self.contact.padma_id, target_type: 'Contact',
                                       object_id: self.id, object_type: 'TrialLesson',
                                       generator: ActivityStream::LOCAL_APP_NAME,
                                       content: I18n.t('trial_lesson.activity_content.deleted'),
                                       verb: 'deleted',
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
    Messaging::Client.post_message('trial_lesson',self.as_json_for_messaging)
  end

  def as_json_for_messaging
    json = as_json
    json["trial_at"] = trial_at
    json["contact_id"] = contact.padma_id
    json["recipient_email"] = contact.padma_contact.email
    json["username"] = padma_uid
    json["account_name"] = account.name
    json
  end  
end
