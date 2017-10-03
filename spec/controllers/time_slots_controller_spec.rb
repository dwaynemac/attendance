require 'spec_helper'

describe TimeSlotsController do

  before do
    @user = sign_in_as_a_valid_user
  end

  describe "GET /time_slots/:id" do
    let!(:ts){create(:time_slot, account_id: @user.current_account_id)}
    let(:st){create(:contact_time_slot,
                     time_slot: ts,
                     contact: create(:accounts_contact, account: @user.current_account, padma_status: 'student').contact).contact}
    let(:fst){create(:contact_time_slot,
                      time_slot: ts,
                      contact: create(:accounts_contact, account: @user.current_account, padma_status: 'former_student').contact).contact}
    before do
      get :show, id: ts.id
    end
    it { should respond_with 200 }
    it "lists students" do
      expect(assigns(:students)).to eq [st]
    end
    it "wont include former_students" do
      expect(assigns(:students)).not_to include fst
    end
  end

  describe "GET /time_slots/vacancies" do
    let(:my_timeslot){create(:time_slot, :account => @user.current_account)}
    let(:not_my_timeslot){create(:time_slot, :account => create(:account))}
    
    let(:cultural){create(:time_slot, cultural_activity: true, :account => @user.current_account)}
    let(:not_cultural){create(:time_slot, cultural_activity: false, :account => @user.current_account)}

    it "responds 200" do
      get :vacancies
      should respond_with 200
    end
    it "includes only time_slots of current account" do
      my_timeslot
      not_my_timeslot
      get :vacancies
      my_timeslot.should be_in assigns(:time_slots)
      not_my_timeslot.should_not be_in assigns(:time_slots)
    end
    it "includes only NON cultural activity timeslots" do
      cultural
      not_cultural
      get :vacancies
      cultural.should_not be_in assigns(:time_slots)
      not_cultural.should be_in assigns(:time_slots)
    end
  end

  describe "GET index" do
    it "assigns all time_slots as @time_slots" do
      time_slot = create(:time_slot, :account => @user.current_account)
      get :index, {}
      assigns(:time_slots).should eq([time_slot])
    end
  end

  describe "GET show" do
    it "assigns the requested time_slot as @time_slot" do
      time_slot = create(:time_slot, :account => @user.current_account)
      get :show, {:id => time_slot.to_param}
      assigns(:time_slot).should eq(time_slot)
    end
  end

  describe "GET new" do
    it "assigns a new time_slot as @time_slot" do
      get :new, {}
      assigns(:time_slot).should be_a_new(TimeSlot)
    end
  end

  describe "GET edit" do
    it "assigns the requested time_slot as @time_slot" do
      time_slot = create(:time_slot, :account => @user.current_account)
      get :edit, {:id => time_slot.to_param}
      assigns(:time_slot).should eq(time_slot)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new TimeSlot" do
        expect {
          post :create, {:time_slot => attributes_for(:time_slot)}
        }.to change(TimeSlot, :count).by(1)
      end

      it "assigns a newly created time_slot as @time_slot" do
        post :create, {:time_slot => attributes_for(:time_slot)}
        assigns(:time_slot).should be_a(TimeSlot)
        assigns(:time_slot).should be_persisted
      end

      it "redirects to the created time_slot" do
        post :create, {:time_slot => attributes_for(:time_slot)}
        response.should redirect_to(TimeSlot.order(:id).last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved time_slot as @time_slot" do
        # Trigger the behavior that occurs when invalid params are submitted
        TimeSlot.any_instance.stub(:save).and_return(false)
        post :create, {:time_slot => {  }}
        assigns(:time_slot).should be_a_new(TimeSlot)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        TimeSlot.any_instance.stub(:save).and_return(false)
        post :create, {:time_slot => {  }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested time_slot" do
        time_slot = create(:time_slot, :account => @user.current_account)
        # Assuming there are no other time_slots in the database, this
        # specifies that the TimeSlot created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        TimeSlot.any_instance.should_receive(:update).with(hash_including({ "these" => "params" }))
        put :update, {:id => time_slot.to_param, :time_slot => { "these" => "params" }}
      end

      it "assigns the requested time_slot as @time_slot" do
        time_slot = create(:time_slot, :account => @user.current_account)
        put :update, {:id => time_slot.to_param, :time_slot => attributes_for(:time_slot)}
        assigns(:time_slot).should eq(time_slot)
      end

      it "redirects to the time_slot" do
        time_slot = create(:time_slot, :account => @user.current_account)
        put :update, {:id => time_slot.to_param, :time_slot => attributes_for(:time_slot)}
        response.should redirect_to(time_slot)
      end
    end

    describe "with invalid params" do
      it "assigns the time_slot as @time_slot" do
        time_slot = create(:time_slot, :account => @user.current_account)
        # Trigger the behavior that occurs when invalid params are submitted
        TimeSlot.any_instance.stub(:save).and_return(false)
        put :update, {:id => time_slot.to_param, :time_slot => {  }}
        assigns(:time_slot).should eq(time_slot)
      end

      it "re-renders the 'edit' template" do
        time_slot = create(:time_slot, :account => @user.current_account)
        # Trigger the behavior that occurs when invalid params are submitted
        TimeSlot.any_instance.stub(:save).and_return(false)
        put :update, {:id => time_slot.to_param, :time_slot => {  }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "sets :deleted to true in requested time_slot" do
      time_slot = create(:time_slot, :account => @user.current_account)
      expect(time_slot.deleted).to be_nil
      delete :destroy, {:id => time_slot.to_param}
      expect(time_slot.reload.deleted).to be_true
    end
    it "DOES NOT destroys the requested time_slot" do
      time_slot = create(:time_slot, :account => @user.current_account)
      expect {
        delete :destroy, {:id => time_slot.to_param}
      }.not_to change(TimeSlot, :count).by(-1)
    end

    it "redirects to the time_slots list" do
      time_slot = create(:time_slot, :account => @user.current_account)
      delete :destroy, {:id => time_slot.to_param}
      response.should redirect_to(time_slots_url)
    end
  end

end
