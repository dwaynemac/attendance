require 'spec_helper'

describe AttendancesController do

  render_views

  before (:each) do
    sign_in_as_a_valid_user
  end

  def current_user
    @user
  end

  def current_account
    @user.current_account
  end

  describe "PATCH /attendances/:id" do
    context "if contacts-ws is online" do
      before do
        PadmaContact.stub!(:find) do |pid|
          PadmaContact.new first_name: pid, last_name: pid, id: pid
        end
      end
      describe "specifying contacts" do
        let!(:ca){create(:contact, padma_id: 'a')}
        let!(:ca){create(:contact, padma_id: 'b')}
        let(:time_slot){create(:time_slot)}
        let!(:attendance){create(:attendance,
                                 padma_contacts: ['a', 'b'],
                                 account: current_account)}
        before do
          patch :update, id: attendance.id,
                attendance: {
            padma_contacts: ['a']
          }
        end
        it "should change attendance contacts" do
          expect(attendance.reload.contacts.map(&:padma_id)).to eq ['a']
        end
      end
    end
  end

  describe "GET /attendances/new" do
    context "if accounts-ws is online" do
      before do
        PadmaUser.stub(:paginate).and_return([PadmaUser.new(name: 'as')])
      end
      let(:time_slot){create(:time_slot)}
      context "if time_slot is specified" do
        before do
          get :new, attendance: {time_slot_id: time_slot.id}
        end
        it { should respond_with 200 }
      end
    end
  end

  describe "GET index" do
    before do 
      Account.any_instance.stub(:usernames).and_return([current_user.username])
    end
    let!(:attendance){create(:attendance, :account => current_account)}
    it "assigns last week's attendances as @attendances" do
      get :index, {}
      assigns(:attendances).should eq([attendance])
    end
  end

  describe "GET /attendances/:id" do
    subject{ controller }
    let(:attendance){ create(:attendance, account: current_account ) }
    context "without trial lesson" do
      before do
        get :show, id: attendance.id
      end
      it { should respond_with 200 }
      it "assigns [] to trial_lessons" do
        expect(assigns(:trial_lessons)).to be_empty
      end
    end
    context "with trial lesson" do
      let!(:trial_lesson){ create(:trial_lesson,
                                  time_slot: attendance.time_slot,
                                  trial_on: attendance.attendance_on)}
      before do
        get :show, id: attendance.id
      end
      it { should respond_with 200 }
      it "assigs trial_lessons to @trial_lessons" do
        expect(assigns(:trial_lessons)).to eq [trial_lesson]
      end
      describe "if trial_lesson's contact is deleted" do
        before do
          trial_lesson.contact_id = nil
          trial_lesson.save validate: false
          get :show, id: attendance.id
        end
        it { should respond_with 200 }
      end
    end
  end

end
