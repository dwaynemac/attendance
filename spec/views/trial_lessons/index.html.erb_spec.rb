require 'spec_helper'

describe "trial_lessons/index" do
  before(:each) do
    assign(:trial_lessons, [
      create(:trial_lesson),
      create(:trial_lesson)
    ])
  end

  it "renders a list of trial_lessons" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
