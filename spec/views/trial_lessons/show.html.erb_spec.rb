require 'rails_helper'

describe "trial_lessons/show" do
  before(:each) do
    TrialLesson.any_instance.stub(:create_activity).and_return(true)
    TrialLesson.any_instance.stub(:broadcast_create).and_return(true)
    @trial_lesson = create(:trial_lesson)
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
