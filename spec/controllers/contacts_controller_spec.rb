require 'spec_helper'

describe ContactsController do

  before do
    sign_in_as_a_valid_user
    create(:contact, padma_id: '123', account: @user.current_account)
  end

  describe "GET /contacts/:padma_id" do
    it "responds 200" do
      get :show, id: '123'
      should respond_with 200
    end
  end
end
