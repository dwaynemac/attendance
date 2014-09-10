require 'spec_helper'

describe AttendanceImport do

  before do
    PadmaContact.stub!(:find_by_kshema_id) do |arg1|
      PadmaContact.new(id: arg1, first_name: 'fn', last_name: 'ln', last_seen_at: 1.day.ago.to_s)
    end

    Contact.any_instance.stub(:padma_contact).and_return(PadmaContact.new(first_name: 'fn', last_name: 'ln', last_seen_at: 1.day.ago.to_s))

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
      PadmaContact.should_receive(:find_by_kshema_id).exactly(13).times do |arg1|
        PadmaContact.new(id: arg1, first_name: 'fn', last_name: 'ln')
      end
      attendance_import.process_CSV
    end

    it "creates local contacts when they dont exist" do
      expect{attendance_import.process_CSV}.to change{Contact.count}.by 13
    end

    it "sets AttendanceContact for every valid row" do
      expect{attendance_import.process_CSV}.to change{AttendanceContact.count}.by 17
    end
    it "should only queue one job to Delayed Job" do
      expect{ attendance_import.process_CSV }.to change{ Delayed::Job.count }.by 1
    end
    it "sets Attendance for every [time_slot_external_id,attendance_on] in rows" do
      expect{attendance_import.process_CSV}.to change{Attendance.count}.by 7
    end
    it "stores in imported_ids ids of created Attendances" do
      attendance_import.process_CSV
      attendance_import.imported_ids.map(&:value).should include AttendanceContact.last.id
    end
    it "stores failed rows numbers" do
      expect{attendance_import.process_CSV}.to change{attendance_import.failed_rows.count}.by 1
    end
    it "sets status to :finished" do
      attendance_import.status.should == :ready
      attendance_import.process_CSV
      attendance_import.status.should == :finished
    end
  end

  describe "only accepts VALID_HEADERS" do
    it "accepts nil"
    it "accepts 'attendance_on'"
    it "reject :some_other"
  end
end
