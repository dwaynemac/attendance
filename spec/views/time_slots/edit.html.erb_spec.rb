require 'spec_helper'

describe "time_slots/edit" do
  before(:each) do
    @time_slot = create(:time_slot)
  end

  it "renders the edit time_slot form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", time_slot_path(@time_slot), "post" do
    end
  end
end
