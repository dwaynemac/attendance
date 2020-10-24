class TimeSlot < ActiveRecord::Base

  default_scope { where("deleted= :false OR deleted IS NULL", false: false).order('name ASC') }

  belongs_to :account
  
  has_many :contact_time_slots
  has_many :contacts, through: :contact_time_slots
  
  has_many :attendances

  has_many :trial_lessons, dependent: :nullify

  validates :account,  :presence => true
  validates :name,  :presence => true #, :uniqueness => {:scope => :account_id}
  validates_time :end_at, :after => :start_at

  # attr_accessible :padma_uid, :name, :start_at, :end_at, :padma_contacts, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :cultural_activity, :external_id, :unscheduled

  before_create :set_defaults

  scope :with_schedule, ->{ rewhere("(monday = :true) or (tuesday = :true) or (wednesday = :true) or (thursday = :true) or (friday = :true) or (saturday = :true) or (sunday = :true)",true: true) }
  scope :without_schedule, ->{ rewhere("(monday = :false OR monday IS NULL) and (tuesday = :false OR tuesday IS NULL) and (wednesday = :false OR wednesday IS NULL) and (thursday = :false OR thursday IS NULL) and (friday = :false OR friday IS NULL) and (saturday = :false OR saturday IS NULL) and (sunday = :false OR sunday IS NULL) and (unscheduled = :false OR unscheduled IS NULL)",false: false) }

  def description
    "#{self.name} (#{self.start_at.hour}#{minutes(self.start_at)}hs-#{self.end_at.hour}#{minutes(self.end_at)}hs)"
  end

  def minutes(hour)
    ":#{hour.min}" unless hour.min.zero?
  end

  def recurrent_contacts
    # Find recurrent_students
    rec_contacts = Attendance
                    .joins(:attendance_contacts)
                    .joins(:attendance_contacts => :contact)
    		    .joins(:attendance_contacts => {:contact => :accounts_contacts})
                    .where('accounts_contacts.account_id = ?', account.id)
                    .where('accounts_contacts.padma_status' => 'student') # Make sure they are still students
                    .where('attendances.time_slot_id' => self.id) # Consider only this timeslot
                    .where('attendances.attendance_on >= ?', 1.month.ago.beginning_of_month) # Filter those who attended this timeslot on the past month
                    .select("contacts.name as first_name, '' as last_name, contacts.padma_id as _id") # Select Contact fields and prepare return as PadmaContacts
    
    # Find this timeslot's students and select fields for result
    ts_contacts = self.contacts.students_on(account).select("contacts.name as first_name, '' as last_name, contacts.padma_id as _id").group('contacts.padma_id, contacts.name')
    
    # Join recurrent and timeslot students and order by name
    (ts_contacts+rec_contacts).uniq {|c| c._id}.sort{|a,b| a.first_name <=> b.first_name }
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

  def description_with_day
    description + " [#{time_slot_days}]"
  end

  def time_slot_days
    response = ""
    days = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
    days.each do |day|
      if send(day)
        response += ", " unless response.empty?
        day_name = I18n.t('date.abbr_day_names')[days.find_index(day)+1]
        response += day_name unless day_name.nil?
      end
    end
    response
  end
  
  def scheduled_for_wday?(wday)
    days = [:sunday,:monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
    send(days[wday])
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
