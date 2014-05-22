class Contact < ActiveRecord::Base
	belongs_to :account

  has_many :contact_time_slots
  has_many :time_slots, through: :contact_time_slots

	has_many :attendance_contacts
	has_many :attendances, through: :attendance_contacts

	validates :account, presence: true

	attr_accessible :account_id, :padma_id, :name, :external_id, :external_sysname, :padma_status

  validates_uniqueness_of :padma_id

	attr_accessor :padma_contact

	def padma_contact(options={})
    if @padma_contact.nil?
      @padma_contact = PadmaContact.find(self.padma_id, {select: [:first_name, :last_name, :email, :last_seen_at], account_name: self.account.name})
    end
    @padma_contact
	end

  # Find or create a local contact by given padma_contact_id
  # @param [String] padma_contact_id ID of contact @ contacts-ws
  # @param [Integer] account_id 
  # @param [PadmaContact] padma_contact (nil)
  # @param [Hash] new_contact_attributes (nil)
  # @return [Contact]
  def self.get_by_padma_id(padma_contact_id,account_id,padma_contact=nil,new_contact_attributes=nil)
    unless contact = Contact.find_by_padma_id(padma_contact_id)
      if padma_contact.nil?
        padma_contact = PadmaContact.find(padma_contact_id, select: [:first_name, :last_name])
      end
      args = {padma_id: padma_contact_id,
              account_id: account_id,
              name: "#{padma_contact.first_name} #{padma_contact.last_name}"}
      if new_contact_attributes
        args = args.merge(new_contact_attributes)
      end
      contact = Contact.create!(args)
    end
    contact
  end

end
