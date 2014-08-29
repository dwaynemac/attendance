require 'spec_helper'

describe ContactsController do

  render_views

  before do
    sign_in_as_a_valid_user
  end

  let!(:contact){create(:contact, padma_id: '123',
                       account: @user.current_account)}

  describe "GET /contacts/:padma_id" do
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
