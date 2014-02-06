namespace :db do
  task :delete_all => :environment do
    if Rails.env.staging?
      [AttendanceContact, AttendanceImport, Attendance, Contact, ContactTimeSlot, ImportDetail, Import, TimeSlot, TrialLesson].each do |k|
        puts "calling delete_all on #{k}"
        k.delete_all
      end
    else
      puts "you are not on staging"
    end
  end
end
