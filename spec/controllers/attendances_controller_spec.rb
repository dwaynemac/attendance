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

  describe "GET /attendances/new" do
    before do
      get :new
    end
    it { should respod_with 200 }
  end

  describe "GET index" do
    let(:attendance){create(:attendance, :account => current_account)}
    it "assigns all attendances as @attendances" do
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
