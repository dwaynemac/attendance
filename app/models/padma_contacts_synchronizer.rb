class PadmaContactsSynchronizer
  attr_accessor :account

  def initialize(account)
    @account = account
  end

  def sync
    page = 1
    more_contacts = true
    while(more_contacts)
      padma_contacts = PadmaContact.search(:select => [:first_name, :last_name], :where => {:updated_at =>  account.synchronized_at},
                        :account_name => account.name,
                        :per_page => 50,
                        :page => page)
      if more_contacts = !padma_contacts.blank?
        padma_contacts.each do |padma_contact|
          contact = Contact.find_by_padma_id(padma_contact.id)
          if contact
            contact_name = "#{padma_contact.try :first_name} #{padma_contact.try :last_name}".strip        
            contact.update_attribute(:name, contact_name) unless contact.name == contact_name
          end  
        end
      end
      page = page + 1
    end
    account.update_attribute(:synchronized_at, Time.now)
  end
end