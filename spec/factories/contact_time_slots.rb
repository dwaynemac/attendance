# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :contact_time_slot do
    time_slot { create(:time_slot) }
    contact { create(:contact) }
  end
end
