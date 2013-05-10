require 'spec_helper'

describe Attendance do
  it "should be valid with default attributes" do
	  build(:attendance).should be_valid
	end

	it "should require an account" do
	  build(:attendance, :account => nil).should_not be_valid
	end	

	it "should require time slot" do
	  build(:attendance, :time_slot => nil).should_not be_valid
	end

	it "should have a date in the past" do
	  build(:attendance, :attendance_on => Date.tomorrow).should_not be_valid
	end
end
