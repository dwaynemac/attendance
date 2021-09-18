require 'rails_helper'

describe TimeSlotImport do
  let(:i18n){ I18n.locale }
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
    I18n.locale = :en
    allow(PadmaContact).to receive(:find_by_kshema_id) do |arg1|
      PadmaContact.new(id: arg1, first_name: 'fn', last_name: 'ln')
    end
  end

  after do
    I18n.locale = i18n
  end

  describe "#process_CSV" do
    it "creates a TimeSlot for every valid row" do
      expect{time_slot_import.process_CSV}.to change{time_slot_import.imported_ids.count}.by 25
    end
    it "sets TimeSlots attributes from rows" do
      time_slot_import.process_CSV
      t = TimeSlot.unscoped.order(:id).last
      expect(t.name).to eq "Entrenamiento de respiracion"
      expect(t.padma_uid).to eq 'leda.bianucci'
      expect(t.monday).to be_truthy
      expect(t.sunday).to be_falsey
    end
    it "links contacts and time_slots" do
      expect{time_slot_import.process_CSV}.to change{ContactTimeSlot.count}.by 5
      t = TimeSlot.unscoped.order(:id).last
      expect(t.contacts.count).to eq 5
    end
    it "stores imported rows ids" do
      expect{time_slot_import.process_CSV}.to change{TimeSlot.count}.by 25
      expect(time_slot_import.reload.imported_ids.map(&:value)).to include(TimeSlot.order(:id).last.id)
    end
    it "stores failed rows numbers" do
      expect{time_slot_import.process_CSV}.to change{time_slot_import.failed_rows.count}.by 1
      expect(time_slot_import.failed_rows.map(&:value)).to eq [4]
    end
    it "sets status to :finished" do
      expect(time_slot_import.status).to eq 'ready'
      time_slot_import.process_CSV
      expect(time_slot_import.status).to eq 'finished'
    end
  end

  describe "only accepts VALID_HEADERS" do
    it "accepts nil" do
      i = TimeSlotImport.new(headers: [nil, 'name'])
      i.valid?
      expect(i.errors[:headers]).to be_empty
    end
    it "accepts :name" do
      i = TimeSlotImport.new(headers: ['name'])
      i.valid?
      expect(i.errors[:headers]).to be_empty
    end
    it "reject :some_other" do
      i = TimeSlotImport.new(headers: ['some_other_header'])
      i.valid?
      expect(i.errors[:headers]).not_to be_empty
    end
  end
end
