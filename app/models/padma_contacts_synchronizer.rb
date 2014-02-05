class PadmaContactsSynchronizer
  attr_accessor :account

  def initialize(account)
    @account = account
  end

  def sync
    contacts = @account.contacts
    padma_contact_ids = contacts.map(&:padma_id).uniq
    padma_contacts = PadmaContact.search(select: [:first_name, :last_name, :status, :global_teacher_username], ids: padma_contact_ids, :where => {:updated_at =>  @account.synchronized_at}, per_page: padma_contact_ids.size, username: @account.try(:padma).try(:admin).try(:username), account_name: @account.name)

    padma_contacts.each do |padma_contact|
    	puts "Updating contact #{padma_contact.first_name} #{padma_contact.last_name} - #{padma_contact.status}"
        contact = contacts.detect {|c| c.padma_id == padma_contact.id} 
        puts "using local_contact #{contact.id}"
        contact.update_attributes(
	        :name => "#{padma_contact.first_name} #{padma_contact.last_name}".strip,
	        :padma_status => padma_contact.status)
    end
    @account.update_attribute(:synchronized_at, DateTime.now)
  end
end