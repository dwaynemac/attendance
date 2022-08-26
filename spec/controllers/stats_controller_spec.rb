require 'rails_helper'

describe StatsController do
  let(:user1){create(:user, username: "123dw.ay_ne@hotmasil.com")}
  before (:each) do
    allow_any_instance_of(Account).to receive(:usernames).and_return [user1.username]
    sign_in_as_a_valid_user
  end
  describe "GET /stats" do
    it "responds 200" do
      get :index
      should respond_with 200
    end
  end

  describe "GET /stats?easy_period=last_month" do
    let(:time_slot){create(:time_slot, :account => @user.current_account, :padma_uid => user1.username)}
    let(:attendance){create(:attendance, :account => @user.current_account, :attendance_on => 1.month.ago, :time_slot => time_slot, :username => user1.username)}
    let(:contact){create(:contact)}

    before do
      allow(CrmLegacyContact).to receive(:search).and_return [user1.username]
      contact.accounts_contacts.create!(:account_id => @user.current_account.id, :padma_status => :student)
      attendance.contacts << contact
    end
    
    it "responds with the correct stats" do
      get :index, 'easy_period' => 'last_month'    
      expect(assigns(:contacts).first.attendance_total).to eq 1
    end
  end
end
