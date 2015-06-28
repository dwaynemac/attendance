require 'spec_helper'

describe TrialLesson do
  it "should be valid with default attributes" do
	  build(:trial_lesson).should be_valid
	end

	it "should require an account" do
	  build(:trial_lesson, :account => nil).should_not be_valid
	end

  describe ".filter" do
    describe "trial_on_lt" do
      let!(:ytrial){ create(:trial_lesson, trial_on: Date.civil(2010,1,1)) }
      let!(:ntrial){ create(:trial_lesson, trial_on: Date.civil(2010,2,1)) }
      let(:result){TrialLesson.filter(trial_on_lt: Date.civil(2010,1,10))}
      it "returns trials that happend before given date" do
        expect(result).to include ytrial
        expect(result).not_to include ntrial
      end
    end
    describe "trial_on_days_ago_lt" do
      let!(:ytrial){ create(:trial_lesson, trial_on: 10.days.ago) }
      let!(:ntrial){ create(:trial_lesson, trial_on: 20.days.ago) }
      let(:result){TrialLesson.filter(trial_on_days_ago_lt: 15)}
      it "returns trials that happend LESS THAN given days ago" do
        expect(result).to include ytrial
        expect(result).not_to include ntrial
      end
    end
  end

  describe "#contact" do
    it "is required" do
      build(:trial_lesson, :contact => nil).should_not be_valid
      build(:trial_lesson, :contact_id => nil).should_not be_valid
    end

    it "is not valid if Contact not persisted" do
      build(:trial_lesson, :contact => Contact.new).should_not be_valid
    end
  end

	it "should require time slot" do
	  build(:trial_lesson, :time_slot => nil).should_not be_valid
	end

	it "should require a user" do
	  build(:trial_lesson, :padma_uid => nil).should_not be_valid
	end

  it "broadcasts a message after create" do
	  tl = build(:trial_lesson)
    tl.should_receive(:broadcast_create)
    tl.save!
  end

  it "skips message broadcast with :skip_broadcast flag" do
	  tl = build(:trial_lesson, skip_broadcast: true)
    tl.should_not_receive(:broadcast_create)
    tl.save!
  end

  describe "trial_at" do
    let(:trial_lesson){create(:trial_lesson)}
    describe "if time_slot was deleted" do
      before { trial_lesson.update_attribute(:time_slot_id, nil)}
      it "return a Date" do
        trial_lesson.trial_at.should be_a Date
      end
    end
    describe "when time_slot it available" do 
      it "returns DateTime" do
        trial_lesson.trial_at.should be_a DateTime
      end
    end
  end
end
