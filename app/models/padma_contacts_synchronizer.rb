class PadmaContactsSynchronizer
  attr_accessor :account

  def initialize(account)
    @account = account
  end

  def sync(wayback = nil)
    wayback ||= 2.days

    since = (@account.synchronized_at || Date.today) - wayback

    # Get all contacts updated since last sync.
    padma_contacts = PadmaContact.search(select: [:first_name,
                                                  :last_name,
                                                  :local_status,
                                                  :local_statuses,
                                                  :global_teacher_username],
                                         where: {
                                           # local_status: [:student, :former_student], -- BUG - currently not working if used with together with updated_at filter
                                           updated_at: since.to_date
                                         },
                                         account_name: @account.name)

    # Iterate over them
    padma_contacts.each do |padma_contact|
      next unless padma_contact.local_status.try(:to_sym).in?([:student,:former_student]) # -- BUG -- filter here until local_status bug solved
      contact = Contact.find_or_create_by padma_id: padma_contact.id

      if contact
        contact.sync_from_contacts_ws(padma_contact)
      end
    end
    @account.update_attribute(:synchronized_at, DateTime.now)
  end
end
