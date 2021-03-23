class AccountsContact < ActiveRecord::Base
  belongs_to :account
  belongs_to :contact

  validates :account, presence: true
  validates :contact, presence: true

  validates_uniqueness_of :contact_id, scope: [:account_id]
  # attr_accessible :account_id, :account, :contact_id, :contact, :padma_status

  # attr_accessible :account_id, :contact_id, :padma_status
end
