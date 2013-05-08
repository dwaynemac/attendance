FactoryGirl.define do
  factory :time_slot do
    sequence(:name) { |n| "Time Slot #{n}"}
    account
    start_at Time.parse('13:00')
	end_at Time.parse('14:00')	
  end
end