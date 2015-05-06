desc "This task is part of a migration from Contact.belongs_to :account to Account.has_many :contacts, :through => :accounts_contacts"
task :habtm_migration  => :environment do
  HabtmMigrator.migrate_all_accounts
  puts "done."
end
