require 'spec_helper'

describe "trial_lessons/show" do
  before(:each) do
    @trial_lesson = create(:trial_lesson)
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end