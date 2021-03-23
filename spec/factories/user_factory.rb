FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "username#{n}"}
    current_account
  end
end