namespace :scheduler do

  #noinspection RubyLiteralArrayInspection
  task :every_10_minutes => [
    #"synchronize"
  ]

  #noinspection RubyLiteralArrayInspection
  task :every_1_day => [
    :update_last_seens
    #"daily_synchronize"
  ]
end

desc "Envia last_seen_at para todas las account que tuvieron asistencia entre ayer y hoy."
task :update_last_seens => :environment do
  Attendance.where(attendance_on: 1.day.ago..Date.today)
            .select("distinct account_id")
            .includes(:account)
            .each do |attendance|
    begin
      LastSeenUpdater.update_account attendance.account.name
    rescue
      # ignore
    end
  end
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
