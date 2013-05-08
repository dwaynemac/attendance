require "spec_helper"

describe TimeSlot do
	it "should be valid with default attributes" do
	  build(:time_slot).should be_valid
	end

	it "should require an account" do
	  build(:time_slot, :account => nil).should_not be_valid
	end	

	it "should require a name" do
	  build(:time_slot, :name => "").should_not be_valid
	end

	it "should require end time is after time" do
	  build(:time_slot, :start_at => Time.parse('14:00'), :end_at => Time.parse('13:00')).should_not be_valid
	end
end