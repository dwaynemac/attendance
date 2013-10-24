# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :import do
    account { Account.last || create(:account) }
    headers []
  end
  factory :time_slot_import do
    account { Account.last || create(:account) }
    headers []
  end
  factory :attendance_slot_import do
    account { Account.last || create(:account) }
    headers []
  end
end
