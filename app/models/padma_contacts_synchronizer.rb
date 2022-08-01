class PadmaContactsSynchronizer
  attr_accessor :account

  def initialize(account)
    @account = account
  end

  def sync(wayback = nil)
    wayback ||= 2.days

    since = (@account.synchronized_at || Date.today) - wayback
    if since < 3.months.ago
      since = 3.months.ago
    end

    padma_contacts = []
    page = 1
    loop do
      contacts_page = CrmLegacyContact.search(
        page: page,
        per_page: 10,
        select: [:first_name,
          :last_name,
          :local_status,
          :local_statuses,
          :global_teacher_username
        ],
        where: {
          updated_after: since.to_date
        },
        account_name: @account.name
      )
      break if contacts_page.blank?
      padma_contacts += contacts_page
      page += 1
    end

    if padma_contacts
      padma_contacts.each do |padma_contact|
        contact = Contact.find_by_padma_id padma_contact.id
        if contact.nil? && padma_contact.local_status.try(:to_sym).in?([:student,:former_student])
          # only create contact if it's a student or former_student, avoid replicating prospects unnecessarily
          contact = Contact.create(padma_id: padma_contact.id)
        end

        if contact
          contact.sync_from_contacts_ws(padma_contact)
        end
      end
      @account.update_attribute(:synchronized_at, DateTime.now)
    end
  end
end
