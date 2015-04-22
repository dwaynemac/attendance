class PadmaContactsSynchronizer
  attr_accessor :account

  def initialize(account)
    @account = account
  end

  def sync
    contacts = @account.contacts

    # Get all contacts updated since last sync.
    padma_contacts = PadmaContact.search(select: [:first_name, :last_name, :local_status, :global_teacher_username], :where => {:local_status => [:student, :former_student], :updated_at =>  @account.synchronized_at}, per_page: 1000, username: @account.try(:padma).try(:admin).try(:username), account_name: @account.name)

    # Iterate over them
    padma_contacts.each do |padma_contact|
        contact = contacts.detect {|c| c.padma_id == padma_contact._id}

        if contact
          # If contact already exists locally update it
          @account.accounts_contacts.find_by_contact_id(contact.id).update_attributes(:padma_status => padma_contact.local_status)
        elsif padma_contact.status == 'student'
	  contact = Contact.find_or_create_by_padma_id(contact.padma_id, :name => "#{padma_contact.first_name} #{padma_contact.last_name}".strip)
          # Otherwise, if its a student, create it locally
          # Prospects dont need to be in sync as TrialLesson can create a local contact if needed.
          @account.account_contacts.create(:contact_id => contact.id, :padma_status => padma_contact.local_status)
      	end
    end
    @account.update_attribute(:synchronized_at, DateTime.now)
  end
end
