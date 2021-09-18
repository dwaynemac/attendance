# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :trial_lesson do
    account { create(:account) }
    contact { create(:contact) }
    time_slot { create(:time_slot) }
    trial_on { Date.tomorrow } 
    sequence(:padma_uid) { |n| "username#{n}"}
  end
end
