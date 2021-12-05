require "crm_legacy_contact"
require "padma_crm_api"

# Representación local del Contacto
# CRM emite un SNS cuando hay cambios y encolo un sync
# En el show via UI también hago un sync
class Contact < ActiveRecord::Base

  include GetsByPadmaId

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

    begin
      pc = CrmLegacyContact.new(id: padma_id)
      pc.update({contact: {last_seen_at: last_seen_at},
                       ignore_validation: true,
                       username: last_attendance.time_slot.padma_uid,
                       account_name: account.name})
    rescue
      Rails.logger.warn "couldnt update last_seen_at for contact #{self.id} ON contacts-ws."
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
    if pc.nil?
      pc = CrmLegacyContact.find(padma_id, select: %W(full_name local_statuses))
    end

    if pc
      update_column :name, "#{pc.first_name} #{pc.last_name}"
      if pc.local_statuses
        pc.local_statuses.each do |ls|
          ls.symbolize_keys!
          a = Account.find_or_create_by name: ls[:account_name]
          if a
            ac = accounts_contacts.where(account_id: a.id).first
            if ac
              ac.update_column :padma_status, ls[:local_status]
            else
              accounts_contacts.create(account_id: a.id,
                padma_status: ls[:local_status])
            end
          end
        end
      end
    end
  end
end
