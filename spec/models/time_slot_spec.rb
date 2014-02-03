require "spec_helper"

describe TimeSlot do
	it "should be valid with default attributes" do
	  build(:time_slot).should be_valid
	end

	it "should require an account" do
	  build(:time_slot, :account => nil).should_not be_valid
	end	

	it "should require a name" do
	  build(:time_slot, :name => "").should_not be_valid
	end

	it "should require end time is after time" do
	  build(:time_slot, :start_at => Time.parse('14:00'), :end_at => Time.parse('13:00')).should_not be_valid
	end

  describe "padma_contacts=" do
    before do
      PadmaContact.stub(:find).and_return(PadmaContact.new())
    end
    let(:ts){create(:time_slot)}
    before do
      a = create(:contact, padma_id: 'this-contact')
      ts.contact_time_slots.create(contact_id: a.id)
      b = create(:contact, padma_id: 'other-contact')
      ts.contact_time_slots.create(contact_id: b.id)
      ts.contacts.count.should == 2
    end
    describe "given an array of padma_ids" do
      it "resets ContactTimeSlot relationship with given padma_ids" do
        ts.padma_contacts = %W(somecontact some-other-contact thirdcontact)
        ts.contacts.count.should == 3
        ts.contacts.map(&:padma_id).should == %W(somecontact some-other-contact thirdcontact)
      end
    end
    describe "given []" do
      it "removes all relationships" do
        ts.padma_contacts = []
        ts.contacts.count.should == 0
        ts.contacts.map(&:padma_id).should == []
      end
    end
  end
end
