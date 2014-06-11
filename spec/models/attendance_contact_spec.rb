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

  describe "if connection contact-ws fails" do
    before do
      PadmaContact.stub(:find).and_return nil
    end

    it "saves attendances anyway" do
      ac = build(:attendance_contact)
      ac.save.should be_true
    end

  end

  describe "if connection to contacts-ws works" do
    before do
      PadmaContact.stub(:find).and_return PadmaContact.new
    end
    it "saves attendances anyway" do
      ac = build(:attendance_contact)
      ac.save.should be_true
    end
  end
end
