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
  
  describe "padma_contacts=" do
    let(:contact){ create(:contact, padma_id: 'contact-a') }
    describe "when account_id is set" do
      let(:att){ create(:attendance) }
      it "sets contact_ids from padma contact ids array" do
        att.padma_contacts = [contact.padma_id]
        expect(att.contact_ids).to eq [contact.id]
      end
    end
    describe "when account_id is nil" do
      let(:att){ build(:attendance, account_id: nil) }
      it "sets contact_ids from padma contact ids array" do
        att.padma_contacts = [contact.padma_id]
        expect(att.contact_ids).to eq [contact.id]
      end
    end
    describe "when time_slot is nil" do
      let(:att){ build(:attendance, time_slot_id: nil) }
      it "sets contact_ids from padma contact ids array" do
        att.padma_contacts = [contact.padma_id]
        expect(att.contact_ids).to eq [contact.id]
      end
    end
    describe "when account AND time_slot are nil" do
      let(:att){ build(:attendance, account_id: nil, time_slot_id: nil) }
      it "fails with exception" do
        expect{att.padma_contacts = [contact.padma_id]}.to raise_exception
      end
    end
  end

  it "allows only one attendance per slot per day" do
    a = build(:attendance)
    a.save! # valid
    inv = build(:attendance,
                account: a.account,
                time_slot: a.time_slot,
                attendance_on: a.attendance_on)
    expect(inv).not_to be_valid
 
    # shouldnt invalidate itself for updates
    create(:contact, padma_id: 'a')
    a.padma_contacts = ['a']
    expect{ a.save! }.not_to raise_exception
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
    account.contacts.delete_all
    contact = create(:contact)
    account.contacts << contact
    Contact.any_instance.stub(:padma_contact).and_return(PadmaContact.new(first_name: 'fn', last_name: 'ln', last_seen_at: 1.day.ago.to_s))
    ts = create(:time_slot, :account => account)
    attendance = create(:attendance, :account => account, :time_slot => ts, :contact_ids => [contact.id])
    attendance.attendance_contacts.should have(1).attendance_contact
  end
end
