class User < ActiveRecord::Base
  attr_accessible :username, :current_account_id

  devise :cas_authenticatable

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
    PadmaContact.paginate(where: {local_status: :student, local_teacher: self.padma_id}, username: self.padma_id, account_name: self.current_account.padma_id)
  end

end
