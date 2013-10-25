class Contact < ActiveRecord::Base
	belongs_to :account
	belongs_to :time_slot

	has_many :attendance_contacts
	has_many :attendances, :through => :attendance_contacts

	validates :account, :presence => true

	attr_accessible :account_id, :padma_id, :name

	attr_accessor :padma_contact

	def padma_contact(options={})
	    if @padma_contact.nil?
	      @padma_contact = PadmaContact.find(self.padma_id, {:select => [:first_name, :last_name, :email], :account_name => self.account.name})
	    end
	    @padma_contact
	end

  # Find or create a local contact by given padma_contact_id
  # @param [String] padma_contact_id ID of contact @ contacts-ws
  # @param [Integer] account_id 
  # @param [PadmaContact] padma_contact (nil)
  # @return [Contact]
  def self.get_by_padma_id(padma_contact_id,account_id,padma_contact=nil)
    unless contact = Contact.find_by_padma_id(padma_contact_id)
      if padma_contact.nil?
        padma_contact = PadmaContact.find(padma_contact_id, select: [:first_name, :last_name])
      end
      contact = Contact.create!(padma_id: padma_contact_id,
                               account_id: account_id,
                               name: "#{padma_contact.first_name} #{padma_contact.last_name}")
    end
    contact
  end

end
