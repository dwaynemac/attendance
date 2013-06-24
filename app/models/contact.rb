class Contact < ActiveRecord::Base
	belongs_to :account
	belongs_to :time_slot

	has_many :attendance_contacts
	has_many :attendances, :through => :attendance_contacts

	validates :account, :presence => true

	attr_accessible :account_id, :padma_id

	attr_accessor :padma_contact

	def padma_contact(options={})
	    if @padma_contact.nil?
	      @padma_contact = PadmaContact.find(self.padma_id, {:account_name => self.account.name})
	    end
	    @padma_contact
	end
end
