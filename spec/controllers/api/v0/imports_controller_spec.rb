require 'spec_helper'

describe Api::V0::ImportsController do
  let(:csv_file) do
    extend ActionDispatch::TestProcess
    fixture_file_upload("/files/belgrano_horarios.csv","text/csv")
  end

  before do
    unless @belgrano = Account.find_by_name('belgrano')
      @belgrano = create(:account, name: 'belgrano') 
    end
  end

  describe "#show" do
    before do
      i = build(:import)
      i.save
      @import_id = i.id
    end
    describe "with a valid id" do
      before do
        get :show, id: @import_id, 
                   app_key: ENV['app_key']
      end
      let(:json){ActiveSupport::JSON.decode(response.body)}
      it { should respond_with 200 }
      it "returns json with import status" do
        json['status'].should == 'ready' 
      end
      it "returns json with failed_rows count" do
        json['failed_rows'].should == 0
      end
      it "returns json with imported_ids count" do
        json['imported_ids'].should == 0
      end
    end
  end

  def post_req(options = {})
    parameters = {
      account_name: 'belgrano',
      import: { csv_file: csv_file,
                headers: ['name'],
                object: 'TimeSlot'
      },
      app_key: ENV['app_key']
    }
    if options[:wout_app_key]
      parameters.delete(:app_key)
    end
    if options[:import]
      parameters[:import] = parameters[:import].merge(options[:import])
    end
    post :create, parameters
  end
  
  describe "#create" do

    it "queues import in delayed_job" do
      expect{ post_req }.to change{Delayed::Job.count}.by 1
    end
    describe "with import[object] TimeSlot" do
      it "creates an TimeSlotImport instance" do
        expect{ post_req(import: {object: 'TimeSlot'}) }.to change{TimeSlotImport.count}.by 1
      end
      it "wont create an AttendanceImport instance" do
        expect{ post_req(import: {object: 'TimeSlot'}) }.not_to change{AttendanceImport.count}
      end
    end
    describe "with import[object] Attendance" do
      it "creates an AttendanceImport instance" do
        expect{ post_req(import: {object: 'Attendance', headers: nil}) }.to change{AttendanceImport.count}.by 1
      end
    end
    describe "with import[object] TrialLesson" do
      pending do
        it "creates an TrialLessonImport instance" do
          expect{ post_req(import: {object: 'TrialLesson'}) }.to change{TrialLessonImport.count}.by 1
        end
      end
      it "wont create an AttendanceImport instance" do
        expect{ post_req(import: {object: 'TrialLesson'}) }.not_to change{AttendanceImport.count}
      end
    end

    it "requires a valid app_key" do
      post_req(wout_app_key: true)
      should respond_with 401

      post_req
      should respond_with 201
    end

    it "should return status 201" do
      post_req
      should respond_with 201
    end

    describe "created import" do
      before { post_req }
      subject{ assigns(:import)  }
      its(:account){ should == @belgrano }
    end

    it "return import instance id" do
      response = post_req
      hash = ActiveSupport::JSON.decode response.body
      hash[:id] = Import.last.id
    end

    it "should get account" do
      post_req
      assigns(:account).name.should == 'belgrano'
    end
  end

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
                  nil] }


  describe "#failed_rows" do
    before do
      @i = build(:time_slot_import, csv_file: csv_file, headers: headers, account_name: 'belgrano')
      @i.save!
      @i.process_CSV
    end
    context 'when CSV file has finished' do
      it "should send data" do
        @controller.should_receive(:send_data).and_return{ @controller.render :nothing => true }
        get :failed_rows, id: @i.id,
                   app_key: ENV['app_key'],
                   format: :csv
      end
    end
  end

end
