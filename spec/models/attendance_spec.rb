require 'spec_helper'

describe Attendance do

  let(:account){ Account.first || create(:account)}
  let(:attendance){ create(:attendance) }

  describe "#trial_lessons" do
    let!(:yes_trial){ create(:trial_lesson, time_slot: attendance.time_slot,
                                           trial_on: attendance.attendance_on)}
    let!(:other_date_trial){ create(:trial_lesson, time_slot: attendance.time_slot)}
    let!(:other_timeslot_trial){ create(:trial_lesson, trial_on: attendance.attendance_on)}

    it "returns trial lessons on the time_slot and date of attendance" do
     expect(attendance.trial_lessons).to eq [yes_trial]
    end
  end

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
    contact = create(:contact, :accounts => [account])
    Contact.any_instance.stub(:padma_contact).and_return(PadmaContact.new(first_name: 'fn', last_name: 'ln', last_seen_at: 1.day.ago.to_s))
    ts = create(:time_slot, :account => account)
    attendance = create(:attendance, :account => account, :time_slot => ts, :contact_ids => [contact.id])
    attendance.attendance_contacts.should have(1).attendance_contact
  end
end
