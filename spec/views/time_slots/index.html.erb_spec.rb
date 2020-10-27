require 'rails_helper'

describe "time_slots/index" do
  before(:each) do
    assign(:unscheduled_time_slots,[])
    assign(:time_slots, [
      create(:time_slot),
      create(:time_slot)
    ])
  end

  it "renders a list of time_slots" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
