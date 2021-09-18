FactoryBot.define do
  factory :accounts_contact do
    account { create(:account) }
    contact { create(:contact) }
  end
end
