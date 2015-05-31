require 'spec_helper'

describe "attendances/index" do
  before(:each) do
    account = create(:account)
    assign(:attendances, [
      create(:attendance, :account => account),
      create(:attendance, :account => account)
    ])

    assign(:time_slots, [
      create(:time_slot, :account => account, monday: true),
      create(:time_slot, :account => account, monday: true)
    ])

    assign(:time_slots_wout_day, [])

    assign(:view_range,(1..7))
    assign(:days_from, 0)
    assign(:days_to, 7)
    assign(:day_span, 7)
    @user = build(:user)
    User.any_instance.stub(:padma_user).and_return(PadmaUser.new(:username => @user.username, :email => "test@test.com"))
    Account.any_instance.stub(:padma).and_return(PadmaAccount.new(:name => @user.current_account.name))
    User.any_instance.stub(:enabled_accounts).and_return([PadmaAccount.new(:name => @user.current_account.name)])
    Account.any_instance.stub(:usernames).and_return(["username"])
    @user.save
    
	view.stub(:current_user) { @user }

  end

  it "renders a list of attendances" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
