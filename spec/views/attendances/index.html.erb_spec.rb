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
  end

  it "renders a list of attendances" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
