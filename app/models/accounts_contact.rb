class AccountsContact < ActiveRecord::Base
  belongs_to :account
  belongs_to :contact

  validates :account, presence: true
  validates :contact, presence: true

  attr_accessible :account_id, :contact_id, :padma_status
end
