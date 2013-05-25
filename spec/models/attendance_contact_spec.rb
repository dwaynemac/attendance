require 'spec_helper'

describe AttendanceContact do
  it "should be valid with default attributes" do
	  build(:attendance_contact).should be_valid
	end

	it "should require an attendance" do
	  build(:attendance_contact, :attendance => nil).should_not be_valid
	end	

	it "should require contact" do
	  build(:attendance_contact, :contact => nil).should_not be_valid
	end
end
