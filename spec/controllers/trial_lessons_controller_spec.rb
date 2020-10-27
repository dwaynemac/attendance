require 'spec_helper'

describe TrialLessonsController do

  before do
    @user = sign_in_as_a_valid_user
  end

  describe "GET index" do
    it "assigns all trial_lessons as @trial_lessons" do
      trial_lesson = create(:trial_lesson, :account => @user.current_account)
      get :index, {}
      expect(assigns(:trial_lessons)).to eq([trial_lesson])
    end
    it "retrieves trial lessons in desc order" do
      tl_now = create :trial_lesson,
                      account: @user.current_account,
                      trial_on: Date.today
      tl_tomorrow = create  :trial_lesson,
                            account: @user.current_account
      get :index, {}
      expect(assigns(:trial_lessons)).to eq([tl_tomorrow, tl_now])
    end
    it "doesn't retrieve archived trial lessons" do
      tl_1 = create(:trial_lesson, :account => @user.current_account)
      tl_2 = create(:trial_lesson, :account => @user.current_account)
      tl_3_archived = create(:trial_lesson, account: @user.current_account, archived: true)
      get :index, {}
      expect(assigns(:trial_lessons).count).to eq 2
    end
  end

  describe "GET show" do
    it "assigns the requested trial_lesson as @trial_lesson" do
      trial_lesson = create(:trial_lesson, :account => @user.current_account)
      get :show, {:id => trial_lesson.to_param}
      expect(assigns(:trial_lesson)).to eq(trial_lesson)
    end
  end

  describe "GET new" do
    it "assigns a new trial_lesson as @trial_lesson" do
      get :new, {}
      expect(assigns(:trial_lesson)).to be_a_new(TrialLesson)
    end
  end

  describe "GET edit" do
    it "assigns the requested trial_lesson as @trial_lesson" do
      trial_lesson = create(:trial_lesson, :account => @user.current_account)
      get :edit, {:id => trial_lesson.to_param}
      expect(assigns(:trial_lesson)).to eq(trial_lesson)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      let(:contact){create(:contact)}
      let(:time_slot){create(:time_slot, account: @user.current_account)}
      it "creates a new TrialLesson" do
        expect {
          @user.current_account.contacts << contact
          post :create, {:trial_lesson => attributes_for(:trial_lesson, time_slot_id: time_slot.id, padma_contact_id: contact.padma_id)}
        }.to change(TrialLesson, :count).by(1)
      end

      it "assigns a newly created trial_lesson as @trial_lesson" do
        post :create, {:trial_lesson => attributes_for(:trial_lesson, time_slot_id: time_slot.id, padma_contact_id: contact.padma_id)}
        expect(assigns(:trial_lesson)).to be_a(TrialLesson)
        expect(assigns(:trial_lesson)).to be_persisted
      end

      it "redirects to the created trial_lesson" do
        post :create, {:trial_lesson => attributes_for(:trial_lesson, time_slot_id: time_slot.id, padma_contact_id: contact.padma_id)}
        expect(response).to redirect_to(TrialLesson.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved trial_lesson as @trial_lesson" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TrialLesson).to receive(:save).and_return(false)
        post :create, {:trial_lesson => {  }}
        expect(assigns(:trial_lesson)).to be_a_new(TrialLesson)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TrialLesson).to receive(:save).and_return(false)
        post :create, {:trial_lesson => {  }}
        expect(response).to redirect_to(new_trial_lesson_url)
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested trial_lesson" do
        trial_lesson = create(:trial_lesson, :account => @user.current_account)
        # Assuming there are no other trial_lessons in the database, this
        # specifies that the TrialLesson created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(TrialLesson).to receive(:update).with({ "padma_uid" => "params" })
        put :update, {:id => trial_lesson.to_param, :trial_lesson => { "padma_uid" => "params" }}
      end

      it "assigns the requested trial_lesson as @trial_lesson" do
        trial_lesson = create(:trial_lesson, :account => @user.current_account)
        put :update, {:id => trial_lesson.to_param, :trial_lesson => attributes_for(:trial_lesson)}
        expect(assigns(:trial_lesson)).to eq(trial_lesson)
      end

      it "redirects to the trial_lesson if :redirect_to is blank" do
        trial_lesson = create(:trial_lesson, :account => @user.current_account)
        put :update, {:id => trial_lesson.to_param, :trial_lesson => attributes_for(:trial_lesson)}
        expect(response).to redirect_to(trial_lessons_path(ref_date: trial_lesson.trial_on))
      end
      it "redirects to the index if :redirect_to equals index" do
        trial_lesson = create(:trial_lesson, :account => @user.current_account)
        put :update, {:id => trial_lesson.to_param, :trial_lesson => attributes_for(:trial_lesson), redirect_to: 'index'}
        expect(response).to redirect_to(trial_lessons_url)
      end
    end

    describe "with invalid params" do
      it "assigns the trial_lesson as @trial_lesson" do
        trial_lesson = create(:trial_lesson, :account => @user.current_account)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TrialLesson).to receive(:save).and_return(false)
        put :update, {:id => trial_lesson.to_param, :trial_lesson => {  }}
        expect(assigns(:trial_lesson)).to eq(trial_lesson)
      end

      it "re-renders the 'edit' template" do
        trial_lesson = create(:trial_lesson, :account => @user.current_account)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TrialLesson).to receive(:save).and_return(false)
        put :update, {:id => trial_lesson.to_param, :trial_lesson => {  }}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested trial_lesson" do
      trial_lesson = create(:trial_lesson, :account => @user.current_account)
      expect {
        delete :destroy, {:id => trial_lesson.to_param}
      }.to change(TrialLesson, :count).by(-1)
    end

    it "redirects to the trial_lessons list" do
      trial_lesson = create(:trial_lesson, :account => @user.current_account)
      ref_date = trial_lesson.trial_on
      delete :destroy, {:id => trial_lesson.to_param}
      expect(response).to redirect_to(trial_lessons_url(ref_date: ref_date))
    end
  end

end
