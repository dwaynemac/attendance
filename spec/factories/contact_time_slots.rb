# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contact_time_slot do
    time_slot
    contact
  end
end
