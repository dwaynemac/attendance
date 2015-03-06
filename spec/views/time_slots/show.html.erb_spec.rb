require 'spec_helper'

describe "time_slots/show" do
  before(:each) do
    @time_slot = create(:time_slot)
    @students = @time_slot.contacts.students
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
