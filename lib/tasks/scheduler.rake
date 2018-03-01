desc "This task is called by the Heroku scheduler add-on it synchronizes recently updated contacts"
task :synchronize  => :environment do
  Account.order(:synchronized_at).all.each do |account|
    if account.padma.enabled?
      puts "Synchronizing Padma Contacts for #{account.name}..."
      PadmaContactsSynchronizer.new(account).sync(1.day)
      puts "done."
    end
  end
end

task :daily_synchronize  => :environment do
  Account.order(:synchronized_at).all.each do |account|
    if account.padma.enabled?
      puts "Synchronizing Padma Contacts for #{account.name}..."
      PadmaContactsSynchronizer.new(account).sync(5.years)
      puts "done."
    end
  end
end
