require 'spec_helper'

describe TimeSlotImport do

  let(:headers){ ['external_id',
                  'name',
                  'padma_uid',
                  'start_at',
                  'end_at',
                  'sunday',
                  'monday',
                  'tuesday',
                  'wednesday',
                  'thursday',
                  'friday',
                  'saturday',
                  'observations',
                  nil,
                  nil,
                  'student_ids'] }

  let(:csv_file) do
    extend ActionDispatch::TestProcess
    fixture_file_upload("/files/belgrano_horarios.csv","text/csv")
  end

  let(:time_slot_import){ create(:time_slot_import, csv_file: csv_file, headers: headers, account: (Account.first || create(:account))) }

  before do
    PadmaContact.stub!(:find_by_kshema_id) do |arg1|
      PadmaContact.new(id: arg1, first_name: 'fn', last_name: 'ln')
    end
  end

  describe "#process_CSV" do
    it "creates a TimeSlot for every valid row" do
      expect{time_slot_import.process_CSV}.to change{time_slot_import.imported_ids.count}.by 25
    end
    it "sets TimeSlots attributes from rows" do
      time_slot_import.process_CSV
      t = TimeSlot.order(:id).last
      t.name.should == "Entrenamiento de respiracion"
      t.padma_uid.should == 'leda.bianucci'
      t.monday.should be_true
      t.sunday.should be_false
    end
    it "links contacts and time_slots" do
      expect{time_slot_import.process_CSV}.to change{ContactTimeSlot.count}.by 5
      t = TimeSlot.order(:id).last
      t.contacts.count.should == 5
    end
    it "stores imported rows ids" do
      expect{time_slot_import.process_CSV}.to change{TimeSlot.count}.by 25
      time_slot_import.reload.imported_ids.map(&:value).should include(TimeSlot.last.id)
    end
    it "stores failed rows numbers" do
      expect{time_slot_import.process_CSV}.to change{time_slot_import.failed_rows.count}.by 1
      time_slot_import.failed_rows.map(&:value).should == [4]
    end
    it "sets status to :finished" do
      time_slot_import.status.should == :ready
      time_slot_import.process_CSV
      time_slot_import.status.should == :finished
    end
  end

  describe "only accepts VALID_HEADERS" do
    it "accepts nil" do
      i = TimeSlotImport.new(headers: [nil, 'name'])
      i.valid?
      i.errors[:headers].should be_empty
    end
    it "accepts :name" do
      i = TimeSlotImport.new(headers: ['name'])
      i.valid?
      i.errors[:headers].should be_empty
    end
    it "reject :some_other" do
      i = TimeSlotImport.new(headers: ['some_other_header'])
      i.valid?
      i.errors[:headers].should_not be_empty
    end
  end
end
