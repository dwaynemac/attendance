require 'rails_helper'

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
      allow_any_instance_of(TrialLesson).to receive(:broadcast_create).and_return(true)
      allow_any_instance_of(TrialLesson).to receive(:create_activity).and_return(true)
      allow(PadmaContact).to receive(:find_by_kshema_id).and_return(
        PadmaContact.new(id: "1", first_name: 'fn', last_name: 'ln')
      )
      allow(PadmaContact).to receive(:find).and_return(PadmaContact.new(id: "1"))
    end
    describe "#process_CSV" do
      it "creates a trial_lesson for every valid row" do
        expect{trial_lesson_import.process_CSV}.to change{trial_lesson_import.imported_ids.count}.by 28
      end
      it "saves imported trial_lesson's ids in imported_ids" do
        expect{trial_lesson_import.process_CSV}.to change{TrialLesson.count}.by 28
        expect(trial_lesson_import.imported_ids.map(&:value)).to include TrialLesson.last.id
      end
      it "saves failed rows in failed_rows" do
        expect{trial_lesson_import.process_CSV}.to change{trial_lesson_import.failed_rows.count}.by 0
      end
      it "sets status to :finished" do
        expect(trial_lesson_import.status).to eq 'ready'
        trial_lesson_import.process_CSV
        expect(trial_lesson_import.status).to eq 'finished'
      end
      it "archives the correct lessons" do
        expect(trial_lesson_import.status).to eq 'ready' 
        trial_lesson_import.process_CSV
        expect(trial_lesson_import.status).to eq 'finished'
        expect(TrialLesson.where(archived: true).count).to eq 7
      end
    end
  end

end
