class AccountsContact < ActiveRecord::Base
  belongs_to :account
  belongs_to :contact

  validates :account, presence: true
  validates :contact, presence: true
end
