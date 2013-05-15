require 'spec_helper'

describe "attendances/index" do
  before(:each) do
    account = create(:account)
    
    assign(:attendances, [
      create(:attendance, :account => account),
      create(:attendance, :account => account)
    ])

    assign(:time_slots, [
      create(:time_slot, :account => account),
      create(:time_slot, :account => account)
    ])
  end

  it "renders a list of attendances" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
