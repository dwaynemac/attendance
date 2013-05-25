class Attendance < ActiveRecord::Base
  belongs_to :account
  belongs_to :time_slot

  has_many :attendance_contacts
  has_many :contacts, through: :attendance_contacts

  validates :account, presence: true
  validates :time_slot, presence: true
  validates :attendance_on, presence: true
  validates_date :attendance_on, on_or_before: :today

  attr_accessor :padma_contacts

  attr_accessible :account_id, :time_slot_id, :attendance_on, :padma_contacts

  def padma_contacts= padma_contacts
  	padma_contacts.each do |padma_contact_id|
    	contact = Contact.find_or_create_by_padma_id(padma_contact_id, account_id: self.account.id)
    	contacts << contact unless contacts.include?(contact)
    end	
  end
end
