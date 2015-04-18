class Contact < ActiveRecord::Base
  has_and_belongs_to_many :accounts

  has_many :contact_time_slots
  has_many :time_slots, through: :contact_time_slots

  has_many :attendance_contacts
  has_many :attendances, through: :attendance_contacts

  has_many :trial_lessons

  attr_accessible :padma_id, :name, :external_id, :external_sysname, :padma_status, :time_slot_ids

  validates_uniqueness_of :padma_id

  scope :students, ->{ where(:padma_status => 'student') }

  attr_accessor :padma_contact

  def padma_contact(options={})
    if @padma_contact.nil?
      @padma_contact = PadmaContact.find(self.padma_id, {select: [:first_name, :last_name, :email, :last_seen_at],
                                                         except: [:except_linked, :except_last_local_status],
                                                         account_name: self.account.name})
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
    account = Account.find(account_id)
    if contact = Contact.find_by_padma_id(padma_contact_id)
      #Local Contact found, associate to account if necessary
      contact.accounts << account unless contact.accounts.include?(account)
    else
      #Local Contact not found, create & associate to account
      
      # Get PadmaContact unless it is already present
      padma_contact = PadmaContact.find(padma_contact_id, select: [:first_name, :last_name, :local_status], :username => account.usernames.try(:first),  :account_name => account.name) unless padma_contact.present?

      #New contact attributes from PadmaContacts
      args = {
              padma_id: padma_contact_id,
              name: "#{padma_contact.first_name} #{padma_contact.last_name}",
              padma_status: padma_contact.local_status
            }


      # Merge with local attributes if they are present
      args = args.merge(new_contact_attributes) if new_contact_attributes.present?
      
      # Create new local Contact associated to account
      contact = account.contacts.create!(args)
    end
    contact
  end

end
