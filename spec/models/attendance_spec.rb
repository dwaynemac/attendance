require 'spec_helper'

describe Attendance do

  let(:account){ Account.first || create(:account)}

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

  it "should create nested attendance_contacts" do
    contact = create(:contact, :account => account)
    ts = create(:time_slot, :account => account)
    attendance = create(:attendance, :account => account, :time_slot => ts, :contact_ids => [contact.id])
    attendance.attendance_contacts.should have(1).attendance_contact
  end
end
