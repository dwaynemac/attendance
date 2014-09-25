require 'spec_helper'

describe ContactsController do

  render_views

  before do
    sign_in_as_a_valid_user
  end

  let!(:contact){create(:contact, padma_id: '123',
                       account: @user.current_account)}

  describe "GET /contacts/:padma_id" do
    let!(:my_time_slot){create(:time_slot,
                               account: @user.current_account)}
    let!(:not_my_time_slot){create(:time_slot)}
    before do
      ContactTimeSlot.create(time_slot: my_time_slot,
                             contact: contact)
      ContactTimeSlot.create(time_slot: not_my_time_slot,
                             contact: contact)
    end
    it "wont show other accounts time_slots" do
      get :show, id: '123'
      expect(assigns(:time_slots)).to include not_my_time_slot
    end
    it "responds 200" do
      get :show, id: '123'
      should respond_with 200
    end
  end

  describe "GET /contacts" do
    context "format: :js" do
      let(:format){:js}
      context "with padma_uid" do
        let(:padma_uid){'12'}
        it "calls contact-ws with sort [:first_name,:asc]" do
          PadmaContact.should_receive(:paginate)
                      .with(hash_including(sort: [:first_name, :asc]))
          get :index, padma_uid: padma_uid, format: format
        end
      end
    end
  end
end
