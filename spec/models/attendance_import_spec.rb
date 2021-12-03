require 'rails_helper'

describe AttendanceImport do

  before do
    allow(CrmLegacyContact).to receive(:find_by_kshema_id) do |arg1|
      CrmLegacyContact.new(id: arg1, first_name: 'fn', last_name: 'ln')
    end

    allow_any_instance_of(Contact).to receive(:padma_contact).and_return(CrmLegacyContact.new(first_name: 'fn', last_name: 'ln'))

    # ensure there are no Attendances
    Attendance.destroy_all
    Contact.delete_all
  end

  let(:headers_time_slot) {
    [ 'external_id',
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
      nil ]
  }

  let(:csv_file_time_slot) do
    extend ActionDispatch::TestProcess
    fixture_file_upload("/files/belgrano_horarios.csv","text/csv")
  end

  let(:time_slot_import) {
    create(:time_slot_import, csv_file: csv_file_time_slot, headers: headers_time_slot, account: (Account.first || create(:account)))
  } 

  let(:headers_attedance) {
  [ nil,
    'time_slot_external_id',
    'contact_external_id',
    'attendance_on',
    nil,
    nil ]
  }
  
  let(:csv_file_attendance) do
    extend ActionDispatch::TestProcess
    fixture_file_upload("/files/belgrano_asistencias.csv","text/csv")
  end

  let(:attendance_import) {create(:attendance_import, headers: headers_attedance, csv_file: csv_file_attendance)}

  describe "#process_CSV" do
    before do
      time_slot_import.process_CSV
    end

    it "calls contacts-ws only once for each kshema_id" do
      expect(CrmLegacyContact).to receive(:find_by_kshema_id).exactly(13).times do |arg1|
        CrmLegacyContact.new(id: arg1, first_name: 'fn', last_name: 'ln')
      end
      attendance_import.process_CSV
    end

    it "creates local contacts when they dont exist" do
      expect{attendance_import.process_CSV}.to change{Contact.count}.by 13
    end

    it "sets AttendanceContact for every valid row" do
      expect{attendance_import.process_CSV}.to change{AttendanceContact.count}.by 17
    end
    it "should not queue last_seen updates to Delayed Job" do
      expect{ attendance_import.process_CSV }.not_to change{ Delayed::Job.count }
    end
    it "should set last_seen_at to every student" do
      expect(LastSeenUpdater).to receive(:update_account)
      attendance_import.process_CSV
    end
    it "sets Attendance for every [time_slot_external_id,attendance_on] in rows" do
      expect{attendance_import.process_CSV}.to change{Attendance.count}.by 7
    end
    it "stores in imported_ids ids of created Attendances" do
      attendance_import.process_CSV
      expect(attendance_import.imported_ids.map(&:value)).to include AttendanceContact.last.id
    end
    it "stores failed rows numbers" do
      expect{attendance_import.process_CSV}.to change{attendance_import.failed_rows.count}.by 1
    end
    it "sets status to :finished" do
      expect(attendance_import.status).to eq 'ready'
      attendance_import.process_CSV
      expect(attendance_import.status).to eq 'finished'
    end
  end

  describe "only accepts VALID_HEADERS" do
    it "accepts nil"
    it "accepts 'attendance_on'"
    it "reject :some_other"
  end
end
