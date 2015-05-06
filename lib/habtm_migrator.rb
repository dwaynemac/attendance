class HabtmMigrator

  attr_accessor :account

  def initialize(account)
    @account = account
  end

  def self.migrate_all_accounts
    Account.all.each do |account|
      migrator = HabtmMigrator.new(account)
      migrator.migrate_all_contacts
    end
  end

  def migrate_all_contacts
    puts "Migrating #{@account.name}..."
    Contact.where(account_id: @account.id).each do |contact|
      migrate_contact(contact)
    end
  end

  def migrate_contact(contact)
    return if contact.account_id.nil?
    puts "- #{contact.name}"
    if @account.accounts_contacts.where(contact_id: contact.id).empty?
      @account.accounts_contacts.create!(contact_id: contact.id,
                                         padma_status: contact.padma_status)
    end
    contact.update_attributes(padma_status: nil,
                              account_id: nil)
  end
end
