# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contact do
    account { Account.last || create(:account) }
    sequence(:padma_id) { |n| "padma_id_#{n}"}
  end
end
