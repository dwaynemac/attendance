# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :contact do
    sequence(:padma_id) { |n| "padma_id_#{n}"}
    after :create do |s|
      s.accounts << FactoryBot.create(:account)
    end
  end
end
