require 'spec_helper'

describe Api::V0::ContactsController do
  describe "GET /api/v0/contacts" do
    before do
      get :show, app_key: ENV['app_key'],
                 id: 'padma-contact-id'
    end

    it { should respond_with 200 }
    
    describe "json" do
      it "includes timeslots"
    end
    
  end
end
