require "crm_legacy_contact"
require "padma_crm_api"

class Contact < ActiveRecord::Base
  has_many :accounts_contacts
  has_many :accounts, through: :accounts_contacts

  has_many :contact_time_slots
  has_many :time_slots, through: :contact_time_slots

  has_many :attendance_contacts
  has_many :attendances, through: :attendance_contacts

  has_many :trial_lessons

  # attr_accessible :padma_id, :name, :external_id, :external_sysname, :padma_status, :time_slot_ids, :account_id

  validates_uniqueness_of :padma_id

  attr_accessor :padma_contact

  def self.students_on(account)
    self.all.joins(:accounts_contacts).where(accounts_contacts: { padma_status: 'student', account_id: account.id })
  end

  def update_last_seen_at(account)
    last_attendance = AttendanceContact.where(contact_id: self.id,
                                              attendances: { account_id: account.id })
                                       .joins(:attendance)
                                       .order("attendances.attendance_on ASC")
                                       .last
                                       .try(:attendance)
    last_seen_at = last_attendance.try(:attendance_on)
    return if last_seen_at.nil?

    if padma_contact(account)
      begin
        padma_contact(account).update({contact: {last_seen_at: last_seen_at},
                                      ignore_validation: true,
                                      username: last_attendance.time_slot.padma_uid,
                                      account_name: account.name})
      rescue
        Rails.logger.warn "couldnt update last_seen_at for contact #{self.id} ON contacts-ws."
      end
    else
      Rails.logger.info "couldnt update last_seen_at for contact #{self.id}"
      raise "couldnt update last_seen_at for contact #{self.id}"
    end
  end

  def padma_contact(account, options={})
    if @padma_contact.nil?
      @padma_contact = CrmLegacyContact.find(self.padma_id, {
        select: [:first_name, :last_name, :email, :last_seen_at],
        except: [:except_linked, :except_last_local_status],
        account_name: account.name
      })
    end
    @padma_contact
  end

  # Syncs local data with data from Contacts-ws
  def sync_from_contacts_ws(pc = nil)
    if pc.nil? || pc.local_statuses.blank?
      pc = CrmLegacyContact.find(padma_id, select: %W(full_name local_statuses))
    end

    if pc
      update_attribute :name, "#{pc.first_name} #{pc.last_name}"
      pc.local_statuses.each do |ls|
        ls.symbolize_keys!
        a = Account.find_or_create_by name: ls[:account_name]
        if a
          ac = accounts_contacts.where(account_id: a.id).first
          if ac
            ac.update_attribute :padma_status, ls[:local_status]
          else
            accounts_contacts.create(account_id: a.id,
                                     padma_status: ls[:local_status])
          end
        end
      end
    end
  end

  # Find or create a local contact by given padma_contact_id
  # @param  padma_contact_id [String] ID of contact @ contacts-ws
  # @param  account_id [Integer]
  # @param  padma_contact [PadmaContact] (nil)
  # @param new_contact_attributes [Hash] (nil)
  # @param resync [Boolean]
  # @return [Contact]
  def self.get_by_padma_id(padma_contact_id,account_id,padma_contact=nil,new_contact_attributes=nil, resync=nil)
    return if padma_contact_id.blank?
      
    account = Account.find(account_id)
    if (contact = Contact.find_by_padma_id(padma_contact_id))
      #Local Contact found, associate to account if necessary
      unless contact.accounts.include?(account)
        # Get PadmaContact unless it is already present
        if padma_contact.blank?
          padma_contact = CrmLegacyContact.find(padma_contact_id,
                                            select: [:first_name, :last_name, :local_status],
                                            username: account.usernames.try(:first),
                                            account_name: account.name)
        end

        if padma_contact.present?
          contact.accounts_contacts.create(account_id: account.id,
                                           padma_status: padma_contact.local_status)
        end
      end

      if resync
        contact.sync_from_contacts_ws(padma_contact)
      end

      contact
    else
      #Local Contact not found, create & associate to account
      
      # Get PadmaContact unless it is already present
      if padma_contact.blank?
        padma_contact = CrmLegacyContact.find(padma_contact_id,
                                          select: [:first_name, :last_name, :local_status],
                                          username: account.usernames.try(:first),
                                          account_name: account.name)
      end
      if padma_contact
        #New contact attributes from PadmaContacts
        args = {
          padma_id: padma_contact_id,
          name: "#{padma_contact.first_name} #{padma_contact.last_name}"
        }

        # Merge with local attributes if they are present
        args = args.merge(new_contact_attributes) if new_contact_attributes.present?

        # Create new local Contact
        contact = Contact.create!(args)

        # Associate to account
        contact.accounts_contacts.create(:account => account, :padma_status => padma_contact.local_status) if padma_contact.present?
      end
    end
    contact
  end

end
