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

  attr_accessible :trial_on, :time_slot_id, :padma_uid, :padma_contact_id

  def padma_contact_id= padma_contact_id
  	self.contact = Contact.find_or_create_by_padma_id(padma_contact_id, account_id: self.time_slot.account.id)
  end

  def padma_contact_id
    self.contact.try(:padma_id)
  end
end
