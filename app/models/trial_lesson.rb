class TrialLesson < ActiveRecord::Base

  include CommentsOnCRM

  belongs_to :account
  belongs_to :contact
  belongs_to :time_slot

  before_validation :set_defaults

  validates :account, presence: true
  validates :contact_id, presence: true
  validates :time_slot, presence: true
  validates :padma_uid, presence: true
  validates :trial_on, presence: true

  attr_accessor :padma_contact_id

  # attr_accessible :trial_on, :time_slot_id, :padma_uid, :padma_contact_id, :assisted, :confirmed, :archived, :absence_reason

  attr_accessor :skip_broadcast
  after_create :broadcast_create, unless: :skip_broadcast

  attr_accessor :avoid_mailing_triggers
  # attr_accessible :avoid_mailing_triggers

  ##
  #
  # For booleans: '1', 1, 't', 'true' and true are considered true
  #               any other is false
  def self.api_where(filters={})
    ret = self.all
    (filters||{}).each_pair do |k,v|
      if md = /^(trial_on|created_at|updated_at)_(.*)$/.match(k)
        attribute = md[1]
        ret = ret.where("#{attribute} #{map_operator(md[2])} ?", v.to_date)
      elsif k == 'assisted'
        ret = ret.where(assisted: booleanize(v)) 
      else
        # direct map filter -> where
        ret = ret.where(k => v)
      end
    end
    ret
  end

  # Day of trial and Time of trial according to TimeSlot's time
  # @return [DateTime]
  def trial_at
    return self.trial_on if time_slot.nil?
    DateTime.civil(trial_on.year,trial_on.month,trial_on.day,time_slot.start_at.hour,time_slot.start_at.min)
  end

  def padma_contact_id= padma_contact_id
    c = Contact.get_by_padma_id(padma_contact_id, self.account_id)
    self.contact_id = c.id if c
  end

  def padma_contact_id
    self.contact.try(:padma_id)
  end

  def broadcast_create
    unless self.skip_broadcast
      # Send notification using the messaging system
      Messaging::Client.post_message('trial_lesson',self.as_json_for_messaging)
    end
  end

  def as_json_for_messaging
    json = as_json
    json["trial_at"] = trial_at
    json["contact_id"] = padma_contact_id
    json["recipient_email"] = contact.padma_contact(account).email
    json["username"] = padma_uid
    json["account_name"] = account.name
    json["avoid_mailing_triggers"] = true if avoid_mailing_triggers == "1" || avoid_mailing_triggers == "true" || avoid_mailing_triggers == true
    json
  end  

  private

  def set_defaults
    self.archived = false if self.archived.nil?
    return true # return true, dont break callback queue
  end

  # maps:
  #   :lt (less than) -> <
  #   :gt (geater than) -> >
  #   :lte -> <=
  #   :gte -> >=
  def self.map_operator(string_operator)
    case string_operator
    when 'lt'
      '<'
    when 'gt'
      '>'
    when 'lte'
      '<='
    when 'gte'
      '>='
    end
  end

  def self.booleanize(value)
    value == true || value == 1 || value == '1' || value == 'true' || value == 't' 
  end

end
