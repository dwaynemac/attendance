class Account < ActiveRecord::Base
  # attr_accessible :name
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :trial_lessons
  has_many :time_slots
  has_many :accounts_contacts
  has_many :contacts, through: :accounts_contacts
  has_many :attendances

  has_many :imports
  has_many :attendance_imports
  has_many :time_slot_imports
  has_many :trial_lesson_imports

  # Hook to Padma Account API
  # @param [TrueClass] cache: Specify if Cache should be used. default: true
  # @return [PadmaAccount]
  def padma(cache=true)
    api = (cache)? Rails.cache.read([self,"padma"]) : nil
    if api.nil?
      api = PadmaAccount.find(self.name)
    end
    Rails.cache.write([self,"padma"], api, :expires_in => 5.minutes) if cache && !api.nil?
    return api
  end

  # Returns usernames of this account
  # @return [Array <String>]
  def usernames
    if @usernames
      @usernames
    else
      users = PadmaUser.paginate(account_name: self.name, per_page: 100)
      @usernames = users.nil? ? nil : users.map(&:username).sort
    end
  end

  # Returns Students of this account
  # @return [Array <String>]
  def students
    CrmLegacyContact.paginate(select: [:first_name, :last_name],
                          where: {local_status: :student},
                          sort: [:first_name, :asc],
                          account_name: self.name,
                          per_page: 1000)
  end
end
