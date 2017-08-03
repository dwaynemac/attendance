class PadmaContactsSynchronizer
  attr_accessor :account

  def initialize(account)
    @account = account
  end

  MAX_ATTEMPTS = 3
  def sync(wayback = nil)
    wayback ||= 2.days

    since = (@account.synchronized_at || Date.today) - wayback

    attempts = 0
    padma_contacts = nil
    while padma_contacts.nil? && attempts < MAX_ATTEMPTS do
      # Get all contacts updated since last sync.
      padma_contacts = PadmaContact.batch_search(select: [:first_name,
                                                    :last_name,
                                                    :local_status,
                                                    :local_statuses,
                                                    :global_teacher_username],
                                           where: {
                                             updated_at: since.to_date
                                           },
                                           account_name: @account.name)
      attempts += 1
    end

    if padma_contacts
      # Iterate over them
      padma_contacts.each do |padma_contact|
        contact = Contact.find_or_create_by padma_id: padma_contact.id

        if contact
          contact.sync_from_contacts_ws(padma_contact)
        end
      end
      @account.update_attribute(:synchronized_at, DateTime.now)
    end
  end
end
