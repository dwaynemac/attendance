# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :attendance do
    account
    time_slot
    attendance_on "2013-05-10"
  end
end
