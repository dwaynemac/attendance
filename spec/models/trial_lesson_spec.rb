require 'spec_helper'

describe TrialLesson do
  it "should be valid with default attributes" do
	  build(:trial_lesson).should be_valid
	end

	it "should require an account" do
	  build(:trial_lesson, :account => nil).should_not be_valid
	end

	it "should require a contact" do
	  build(:trial_lesson, :contact => nil).should_not be_valid
	end	

	it "should require time slot" do
	  build(:trial_lesson, :time_slot => nil).should_not be_valid
	end

	it "should require a user" do
	  build(:trial_lesson, :padma_uid => nil).should_not be_valid
	end
end
