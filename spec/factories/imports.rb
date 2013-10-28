# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :import do
    account { Account.last || create(:account) }
  end
  factory :time_slot_import do
    account { Account.last || create(:account) }
  end
  factory :attendance_import do
    account { Account.last || create(:account) }
  end
  factory :trial_lesson_import do
    account { Account.last || create(:account) }
  end
end
