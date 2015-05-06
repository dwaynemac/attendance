desc "This task is part of a migration from Contact.belongs_to :account to Account.has_many :contacts, :through => :accounts_contacts"
task :habtm_migration  => :environment do
  Account.all.each do |account|
    puts "Migrating #{account.name}..."
    Contact.where(account_id: account.id).each do |contact|
      puts "- #{contact.name}"
      if account.accounts_contacts.where(contact_id: contact.id).empty?
        account.accounts_contacts.create(contact_id: contact.id,
                                         padma_status: contact.padma_status)
      end
      contact.update_attributes(local_status: nil,
                                account_id: nil)
    end
    puts "done."
  end
end
