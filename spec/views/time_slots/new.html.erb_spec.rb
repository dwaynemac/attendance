require 'rails_helper'

describe "time_slots/new" do
  before(:each) do
    assign(:time_slot, build(:time_slot))

	@user = build(:user)
    User.any_instance.stub(:padma_user).and_return(PadmaUser.new(:username => @user.username, :email => "test@test.com"))
    Account.any_instance.stub(:padma).and_return(PadmaAccount.new(:name => @user.current_account.name))
    User.any_instance.stub(:enabled_accounts).and_return([PadmaAccount.new(:name => @user.current_account.name)])
    Account.any_instance.stub(:usernames).and_return(["username"])
    @user.save
    
	view.stub(:current_user) { @user }
    
  end

  it "renders new time_slot form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", time_slots_path, "post" do
    end
  end
end
