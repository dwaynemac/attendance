# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :import do
    account { Account.last || create(:account) }
    headers []
  end
end
