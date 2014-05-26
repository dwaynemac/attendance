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
          contact.update_attributes(
	        :name => "#{padma_contact.first_name} #{padma_contact.last_name}".strip,
	        :padma_status => padma_contact.local_status)
        elsif padma_contact.status == 'student'
          # Otherwise, if its a student, create it locally
          # Prospects dont need to be in sync as TrialLesson can create a local contact if needed.
          @account.contacts.create(
            :name => "#{padma_contact.first_name} #{padma_contact.last_name}".strip,
            :padma_status => padma_contact.local_status)
      	end
    end
    @account.update_attribute(:synchronized_at, DateTime.now)
  end
end