# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contact do
    sequence(:padma_id) { |n| "padma_id_#{n}"}
    after :create do |s|
      s.accounts << FactoryGirl.create(:account)
    end
  end
end
