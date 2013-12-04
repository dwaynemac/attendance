require 'spec_helper'

describe AttendancesController do

  before (:each) do
    sign_in_as_a_valid_user
  end

  describe "GET index" do
    it "assigns all attendances as @attendances" do
      attendance = create(:attendance, :account => @user.current_account)
      get :index, {}
      assigns(:attendances).should eq([attendance])
    end
  end

end
