FactoryGirl.define do
  factory :account, :aliases => [:current_account] do
    sequence(:name) {|n| "Account #{n}" }
  end
end