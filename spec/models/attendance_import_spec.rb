require 'spec_helper'

describe AttendanceImport do

  before do
    PadmaContact.stub!(:find_by_kshema_id).and_return(
      PadmaContact.new(first_name: 'fn', last_name: 'ln')
    )
  end

  let(:headers){[
    nil,
    'time_slot_external_id',
    'contact_external_id',
    'attendance_on',
    nil,
    nil
  ]}
  let(:csv_file) do
    extend ActionDispatch::TestProcess
    fixture_file_upload("/files/belgrano_asistencias.csv","text/csv")
  end
  let(:attendance_import){create(:attendance_import, headers: headers, csv_file: csv_file)}

  describe "#process_CSV" do
    it "sets AttendanceContact for every valid row" do
      expect{attendance_import.process_CSV}.to change{AttendanceContact.count}.by 18
    end
    it "sets Attendance for every [time_slot_external_id,attendance_on] in rows" do
      expect{attendance_import.process_CSV}.to change{Attendance.count}.by 1
    end
    it "stores in imported_ids ids of created Attendances" do
      attendance_import.process_CSV
      attendance_import.imported_ids.should include Attendance.last.id
    end
    it "stores failed rows numbers" do
      expect{attendance_import.process_CSV}.not_to change{attendance_import.failed_rows.count}
    end
    it "sets status to :finished" do
      attendance_import.status.should == :'ready'
      attendance_import.process_CSV
      attendance_import.status.should == :'finished'
    end
  end

  describe "only accepts VALID_HEADERS" do
    it "accepts nil"
    it "accepts 'attendance_on'"
    it "reject :some_other"
  end
end
