class Account < ActiveRecord::Base
  attr_accessible :name
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :time_slots
  has_many :contacts

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
    users = PadmaUser.paginate(account_name: self.name, per_page: 100)
    users.nil? ? nil : users.map(&:username)
  end

  # Returns Students of this account
  # @return [Array <String>]
  def students
    PadmaContact.paginate(where: {local_status: :student}, account_name: self.name, per_page: 1000)
  end
end
