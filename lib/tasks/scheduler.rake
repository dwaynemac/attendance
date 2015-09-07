desc "This task is called by the Heroku scheduler add-on it synchronizes recently updated contacts"
task :synchronize  => :environment do
  Account.order(:synchronized_at).all.each do |account|
    if account.padma.enabled?
      puts "Synchronizing Padma Contacts for #{account.name}..."
      PadmaContactsSynchronizer.new(account).sync
      puts "done."
    end
  end
end
