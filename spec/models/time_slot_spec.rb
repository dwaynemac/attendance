require "rails_helper"

describe TimeSlot do
  let(:i18n){ I18n.locale }
  before do
    I18n.locale = :en
  end

  after do
    I18n.locale = i18n
  end
  
  it { should have_many :trial_lessons }

  describe "time_slot_days" do
    let!(:ts){ create(:time_slot, monday: true) }
    let!(:ts_w_s){ create(:time_slot) }

    expected = "Mon"
    it "should render '#{expected}'" do
      expect(ts.time_slot_days).to eq expected
    end

    it "should render ''" do
      expect(ts_w_s.time_slot_days).to eq ''
    end

  end
  
  describe "has schedule scopes:" do
    let!(:with_sched){ create(:time_slot, monday: true) }
    let!(:without_sched_all_nil){ create(:time_slot) }
    let!(:without_sched_with_false){ create(:time_slot, monday: false) }
    describe ".with_schedule" do
      subject{TimeSlot.with_schedule}
      it { should include(with_sched) }
      it { should_not include(without_sched_all_nil) }
      it { should_not include(without_sched_with_false) }
    end
    describe ".without_schedule" do
      subject{TimeSlot.without_schedule}
      it { should_not include(with_sched) }
      it { should include(without_sched_all_nil) }
      it { should include(without_sched_with_false) }
    end
  end

	it "should be valid with default attributes" do
	  expect(build(:time_slot)).to be_valid
	end

	it "should require an account" do
	  expect(build(:time_slot, :account => nil)).not_to be_valid
	end	

	it "should require a name" do
	  expect(build(:time_slot, :name => "")).not_to be_valid
	end

	it "should require end time is after time" do
	  expect(build(:time_slot, :start_at => Time.parse('14:00'), :end_at => Time.parse('13:00'))).not_to be_valid
	end

  describe "padma_contacts=" do
    before do
      allow(PadmaContact).to receive(:find).and_return(PadmaContact.new())
    end
    let(:ts){create(:time_slot)}
    before do
      a = create(:contact, padma_id: 'this-contact')
      ts.contact_time_slots.create(contact_id: a.id)
      b = create(:contact, padma_id: 'other-contact')
      ts.contact_time_slots.create(contact_id: b.id)
      expect(ts.contacts.count).to eq 2
    end
    describe "given an array of padma_ids" do
      it "resets ContactTimeSlot relationship with given padma_ids" do
        ts.padma_contacts = %W(somecontact some-other-contact thirdcontact)
        expect(ts.contacts.count).to eq 3
        expect(ts.contacts.map(&:padma_id)).to eq %W(somecontact some-other-contact thirdcontact)
      end
    end
    describe "given []" do
      it "removes all relationships" do
        ts.padma_contacts = []
        expect(ts.contacts.count).to eq 0
        expect(ts.contacts.map(&:padma_id)).to eq []
      end
    end
  end
end
