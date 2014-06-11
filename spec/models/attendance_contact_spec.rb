require 'spec_helper'

describe AttendanceContact do
  it "should be valid with default attributes" do
	  build(:attendance_contact).should be_valid
	end

	it "should require an attendance" do
	  build(:attendance_contact, attendance: nil).should_not be_valid
	end	

	it "should require contact" do
	  build(:attendance_contact, contact: nil).should_not be_valid
	end

  describe "when saved" do

    describe "if connection to contact-ws fails" do
      before do
        PadmaContact.stub(:find).and_return nil
      end

      it "saves attendances anyway" do
        ac = build(:attendance_contact)
        ac.save.should be_true
      end
      it "queues delayed job to set last_seen_at" do
        expect do
          ac = build(:attendance_contact)
          ac.save.should be_true
        end.to change{ Delayed::Job.count }
      end

    end

    describe "if connection to contacts-ws works" do
      before do
        PadmaContact.stub(:find).and_return PadmaContact.new
      end
      it "saves attendances" do
        ac = build(:attendance_contact)
        ac.save.should be_true
      end
      it "queues delayed job to set last_seen_at" do
        expect do
          ac = build(:attendance_contact)
          ac.save.should be_true
        end.to change{ Delayed::Job.count }
      end
    end
  end

  describe "#set_last_seen_at_on_contacts" do
    describe "if connection to contact-ws fails" do
      before do
        PadmaContact.stub(:find).and_return nil
      end

      it "raises exception with a readable message" do
        ac = build(:attendance_contact)
        expect{ac.set_last_seen_at_on_contacts}.to raise_exception "attendance #{ac.attendance.id} couldnt update last_seen_at for contact #{ac.contact.id}"
      end

    end

    describe "if connection to contacts-ws works" do
      before do
        PadmaContact.stub(:find).and_return PadmaContact.new
      end
      it "wont raise exception" do
        ac = build(:attendance_contact)
        expect{ac.set_last_seen_at_on_contacts}.not_to raise_exception
      end
    end
  end
end
