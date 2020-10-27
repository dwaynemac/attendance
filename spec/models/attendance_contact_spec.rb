require 'spec_helper'

describe AttendanceContact do
  it "should be valid with default attributes" do
	  expect(build(:attendance_contact)).to be_valid
	end

	it "should require an attendance" do
	  expect(build(:attendance_contact, attendance: nil)).not_to be_valid
	end	

	it "should require contact" do
	  expect(build(:attendance_contact, contact: nil)).not_to be_valid
	end

  describe "when saved" do

    describe "if connection to contact-ws fails" do
      before do
        allow(PadmaContact).to receive(:find).and_return nil
      end

      it "saves attendances anyway" do
        ac = build(:attendance_contact)
        expect(ac.save).to be_truthy
      end
      it "queues delayed job to set last_seen_at" do
        expect do
          ac = build(:attendance_contact)
          expect(ac.save).to be_truthy
        end.to change{ Delayed::Job.count }
      end

    end

    describe "if connection to contacts-ws works" do
      before do
        allow(PadmaContact).to receive(:find).and_return PadmaContact.new
      end
      it "saves attendances" do
        ac = build(:attendance_contact)
        expect(ac.save).to be_truthy
      end
      it "queues delayed job to set last_seen_at" do
        expect do
          ac = build(:attendance_contact)
          expect(ac.save).to be_truthy
        end.to change{ Delayed::Job.count }
      end
      context "and skip_update_last_seen_at flag is set to true" do
        it "should not queue delayed job to set last_seen_at" do
          expect do
            ac = build(:attendance_contact, skip_update_last_seen_at: true)
            expect(ac.save).to be_truthy
          end.not_to change { Delayed::Job.count }
        end
      end
    end
  end

  describe "#set_last_seen_at_on_contacts" do
    describe "if connection to contact-ws fails" do
      before do
        allow(PadmaContact).to receive(:find).and_return nil
      end

      it "raises exception with a readable message" do
        ac = create(:attendance_contact)
        expect{ac.set_last_seen_at_on_contacts}.to raise_exception "couldnt update last_seen_at for contact #{ac.contact.id}"
      end

    end

    describe "if connection to contacts-ws works" do
      before do
        allow(PadmaContact).to receive(:find).and_return PadmaContact.new
      end
      it "wont raise exception" do
        ac = build(:attendance_contact)
        expect{ac.set_last_seen_at_on_contacts}.not_to raise_exception
      end
    end
  end
end
