# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trial_lesson do
    account
    contact
    time_slot
    trial_on Date.tomorrow
    sequence(:padma_uid) { |n| "username#{n}"}
  end
end
