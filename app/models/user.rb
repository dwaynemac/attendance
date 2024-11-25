class User < ActiveRecord::Base
  # attr_accessible :username, :current_account_id

  devise :database_authenticatable
  def encrypted_password
  end

  validates_uniqueness_of :username
  validates_presence_of :username

  include Accounts::IsAUser

  belongs_to :current_account, :class_name => "Account"

  # Accounts::IsAUser needs class to respond_to account_name
  def account_name
    self.current_account.try :name
  end

  # Accounts::IsAUser needs class to respond_to account_name=
  def account_name=(name)
    self.current_account = Account.find_by_name(name)
  end

  # Accounts::IsAUser needs class to respond_to account_name_changed?
  def account_name_changed?
    self.current_account_id_changed?
  end

  def students
    CrmLegacyContact.paginate(select: [:first_name, :last_name], where: {local_status: :student, local_teacher: self.padma_id}, username: self.padma_id, account_name: self.current_account.padma_id)
  end

  def self.full_name_for(username)
    return "" if username.blank?

    Rails.cache.fetch("user/#{username}/full_name", expires_in: 7.days) do
      find_by(username: username).try(:padma).try(:full_name).presence || username
    end
  end

end
