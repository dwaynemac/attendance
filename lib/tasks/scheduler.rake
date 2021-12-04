namespace :scheduler do

  #noinspection RubyLiteralArrayInspection
  task :every_10_minutes => [
    #"synchronize"
  ]

  #noinspection RubyLiteralArrayInspection
  task :every_1_day => [
    #"daily_synchronize"
  ]
end

desc "This task is called by the Heroku scheduler add-on it synchronizes recently updated contacts"
task :synchronize  => :environment do
  Account.order(:synchronized_at).all.each do |account|
    if account.padma && account.padma.enabled?
      puts "Synchronizing Padma Contacts for #{account.name}..."
      PadmaContactsSynchronizer.new(account).sync(30.minutes)
      puts "done."
    end
  end
end

task :daily_synchronize  => :environment do
  Account.order(:synchronized_at).all.each do |account|
    if account.padma && account.padma.enabled?
      puts "Synchronizing Padma Contacts for #{account.name}..."
      PadmaContactsSynchronizer.new(account).sync(2.days)
      puts "done."
    end
  end
end
