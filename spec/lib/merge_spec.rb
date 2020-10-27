require 'merge'
require 'rails_helper'

describe Merge do

  before do
    PadmaContact.stub(:find).and_return PadmaContact.new
  end

  let(:son_id){ 'son-id' }
  let(:father_id){ 'father_id' }
  let(:m){ Merge.new(son_id, father_id) }

  describe "#merge" do
    describe "if there is no Contact with father padma_id" do
      let!(:son){ create(:contact, padma_id: son_id) }
      it "changes Contact son_id to father_id" do
        expect{ m.merge }.not_to change{Contact.count}
        expect(son.reload.padma_id).to eq father_id
      end
    end
    describe "if there is no Contact with son_id" do
      it "nothing changes" do
        expect{ m.merge }.not_to change{Contact.count}
        expect{ m.merge }.not_to raise_exception
      end
    end
    describe "if there is a Contact with son_id and another with father_id" do
      let!(:son){ create(:contact, padma_id: son_id) }
      let!(:father){ create(:contact, padma_id: father_id) }

      it "deletes son" do
        m.merge
        expect{ Contact.find(son.id) }.to raise_exception
      end

      let!(:son_trial){ create(:trial_lesson, contact: son) }

      it "moves trial_lessons from son to father" do
        expect{ m.merge }.to change{ Contact.count }.by -1
        expect(son_trial.reload.contact).to eq father
      end

      # both in same attendance
      let!(:son_attendance){ create(:attendance_contact, contact: son) }
      let!(:father_attendance){ create(:attendance_contact, contact: father, attendance: son_attendance.attendance) }

      let!(:son_own_attendance){ create(:attendance_contact, contact: son) }
      let!(:father_own_attendance){ create(:attendance_contact, contact: father) }

      it "moves attendances from son to father avoiding duplicates" do
        expect{ m.merge }.to change{AttendanceContact.count}.by -1
        expect(son_own_attendance.reload.contact_id).to eq father.id
      end

      xit "queues recalculation of last_seen_at on each linked account" do
        Delayed::Worker.delay_jobs = false
        father.should_receive(:update_last_seen_at).with(father_attendance.attendance.account,son_own_attendance.attendance.account,father_own_attendance.attendance.account).and_return(true,true,true)
        m.merge
      end

      # both in same timeslot
      let!(:son_timeslot){ create(:contact_time_slot, contact: son) }
      let!(:father_timeslot){ create(:contact_time_slot, contact: father, time_slot: son_timeslot.time_slot) }

      let!(:son_own_timeslot){ create(:contact_time_slot, contact: son) }
      let!(:father_own_timeslot){ create(:contact_time_slot, contact: father) }

      it "moves timeslot assignations from son to father avoiding dupliacates" do
        expect{ m.merge }.to change{ContactTimeSlot.count}.by -1
        expect(son_own_timeslot.reload.contact_id).to eq father.id
      end

      # both in same timeslot
      let!(:son_account){ create(:accounts_contact, contact: son) }
      let!(:father_account){ create(:accounts_contact, contact: father, account: son_account.account) }

      let!(:son_own_account){ create(:accounts_contact, contact: son) }
      let!(:father_own_account){ create(:accounts_contact, contact: father) }
      it "assigns father to all accounts son was assigned avoiding duplicates" do
        expect{ m.merge }.to change{AccountsContact.count}.by -1
        expect(son_own_account.reload.contact_id).to eq father.id
      end

    end
  end
  
end
