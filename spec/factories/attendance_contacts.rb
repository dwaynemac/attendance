# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :attendance_contact do
    attendance
    contact
  end
end
