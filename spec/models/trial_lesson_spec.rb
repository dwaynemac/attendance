require 'rails_helper'

describe TrialLesson do
  it "should be valid with default attributes" do
	  expect(build(:trial_lesson)).to be_valid
	end

	it "should require an account" do
	  expect(build(:trial_lesson, :account => nil)).not_to be_valid
	end

  describe ".api_where" do
    describe "assisted" do
      let!(:ytrial){ create(:trial_lesson, assisted: true) }
      let!(:ntrial){ create(:trial_lesson, assisted: false) }
      let(:result){TrialLesson.api_where(assisted: true)}
      it "returns trials that happend before given date" do
        expect(result).to include ytrial
        expect(result).not_to include ntrial
      end
    end
    describe "trial_on_lt" do
      let!(:ytrial){ create(:trial_lesson, trial_on: Date.civil(2010,1,1)) }
      let!(:ntrial){ create(:trial_lesson, trial_on: Date.civil(2010,2,1)) }
      let(:result){TrialLesson.api_where(trial_on_lt: Date.civil(2010,1,10))}
      it "returns trials that happend before given date" do
        expect(result).to include ytrial
        expect(result).not_to include ntrial
      end
    end
  end

  describe "#contact" do
    it "is required" do
      expect(build(:trial_lesson, :contact => nil)).not_to be_valid
      expect(build(:trial_lesson, :contact_id => nil)).not_to be_valid
    end

    it "is not valid if Contact not persisted" do
      expect(build(:trial_lesson, :contact => Contact.new)).not_to be_valid
    end
  end

	it "should require time slot" do
	  expect(build(:trial_lesson, :time_slot => nil)).not_to be_valid
	end

	it "should require a user" do
	  expect(build(:trial_lesson, :padma_uid => nil)).not_to be_valid
	end

  it "broadcasts a message after create" do
	  tl = build(:trial_lesson)
    expect(tl).to receive(:broadcast_create)
    tl.save!
  end

  it "skips message broadcast with :skip_broadcast flag" do
	  tl = build(:trial_lesson, skip_broadcast: true)
    expect(tl).not_to receive(:broadcast_create)
    tl.save!
  end

  describe "trial_at" do
    let(:trial_lesson){create(:trial_lesson)}
    describe "if time_slot was deleted" do
      before { trial_lesson.update_attribute(:time_slot_id, nil)}
      it "return a Date" do
        expect(trial_lesson.trial_at).to be_a Date
      end
    end
    describe "when time_slot it available" do 
      it "returns DateTime" do
        expect(trial_lesson.trial_at).to be_a DateTime
      end
    end
  end
end
