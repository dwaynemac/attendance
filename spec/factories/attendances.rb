# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :attendance do
    account { create(:account) }
    time_slot { create(:time_slot) }
    attendance_on { Date.yesterday } 
    username {'username'}
  end
end
