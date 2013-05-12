require 'spec_helper'

describe AttendancesController do

  before (:each) do
    @user = build(:user)
    User.any_instance.stub(:padma_user).and_return(PadmaUser.new(:username => @user.username, :email => "test@test.com"))
    Account.any_instance.stub(:padma).and_return(PadmaAccount.new(:name => @user.current_account.name))
    User.any_instance.stub(:enabled_accounts).and_return([PadmaAccount.new(:name => @user.current_account.name)])
    @user.save
    sign_in @user
  end

  describe "GET index" do
    it "assigns all attendances as @attendances" do
      attendance = create(:attendance, :account => @user.current_account)
      get :index, {}
      assigns(:attendances).should eq([attendance])
    end
  end

end
