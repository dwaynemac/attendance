require 'spec_helper'

describe TrialLessonImport do

  before(:all) do
    # import TimeSlots
    extend ActionDispatch::TestProcess
    headers_time_slot =  ['external_id','name','padma_uid','start_at','end_at','sunday','monday','tuesday','wednesday','thursday','friday','saturday','observations',nil,nil]
    csv_file_time_slot = fixture_file_upload("/files/belgrano_horarios.csv","text/csv")
    time_slot_import = create(:time_slot_import, csv_file: csv_file_time_slot, headers: headers_time_slot, account: (Account.first || create(:account)))
    time_slot_import.process_CSV
  end

  let(:headers){[
    nil,
    'contact_external_id',
    'time_slot_external_id',
    'padma_uid',
    'trial_on',
    nil, # created_at
    nil, # updated_at
    'archived', # olvidar
    nil, # motivo_ausencia
    nil, # confirmed
    'assisted'
  ]}

  let(:csv_file) do
    extend ActionDispatch::TestProcess
    fixture_file_upload("/files/belgrano_pruebas.csv","text/csv")
  end

  let(:trial_lesson_import){ create(:trial_lesson_import, csv_file: csv_file, headers: headers, account: (Account.first || create(:account))) }

  describe "with external webservices working ok" do
    before(:each) do
      # avoid calls to external WSs
      TrialLesson.any_instance.stub(:broadcast_create).and_return(true)
      TrialLesson.any_instance.stub(:create_activity).and_return(true)
      PadmaContact.stub(:find_by_kshema_id).and_return(
        PadmaContact.new(id: "1", first_name: 'fn', last_name: 'ln')
      )
      PadmaContact.stub(:find).and_return(PadmaContact.new(id: "1"))
    end
    describe "#process_CSV" do
      it "creates a trial_lesson for every valid row" do
        expect{trial_lesson_import.process_CSV}.to change{trial_lesson_import.imported_ids.count}.by 28
      end
      it "saves imported trial_lesson's ids in imported_ids" do
        expect{trial_lesson_import.process_CSV}.to change{TrialLesson.count}.by 28
        trial_lesson_import.imported_ids.map(&:value).should include TrialLesson.last.id
      end
      it "saves failed rows in failed_rows" do
        expect{trial_lesson_import.process_CSV}.to change{trial_lesson_import.failed_rows.count}.by 0
      end
      it "sets status to :finished" do
        trial_lesson_import.status.should == :ready
        trial_lesson_import.process_CSV
        trial_lesson_import.status.should == :finished
      end
      it "archives the correct lessons" do
        trial_lesson_import.status.should == :ready
        trial_lesson_import.process_CSV
        trial_lesson_import.status.should == :finished
        TrialLesson.where(archived: true).count.should == 7
      end
    end
  end

end
