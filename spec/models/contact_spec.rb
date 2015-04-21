require 'spec_helper'

describe Contact do
  it { have_many(:accounts).through(:accounts_contact) }

  let(:account){ Account.first || create(:account)}

  describe "#time_slot_ids=" do
    # provided by has_many :time_slots
    let(:time_slot){create(:time_slot)}
    let(:padma_id){'contact-id'}
    let(:contact){create(:contact, padma_id: padma_id)}
    it "sets contact times_slots" do
      expect(contact.time_slots).to eq []
      contact.time_slot_ids = [time_slot.id]
      expect(contact.time_slots).to eq [time_slot]
      expect(contact.reload.time_slots).to eq [time_slot]
    end
  end

  describe ".get_by_padma_id" do
    let(:padma_id){'contact-id'}
    describe "if already cached" do
      before do
        @contact = Contact.find_by_padma_id(padma_id) || create(:contact, padma_id: padma_id)
      end
      it "finds local_contact with given padma_id" do
        Contact.get_by_padma_id(padma_id,account.id).should == @contact
      end
      it "wont create a new contact" do
        expect{Contact.get_by_padma_id(padma_id,account.id)}.not_to change{Contact.count}
      end
      it "associates the contact to the account" do
	expect{Contact.get_by_padma_id(padma_id, account.id).accounts.includes? account}
      end
    end
    describe "if not cached" do
      before do
        Contact.where(padma_id: padma_id).delete_all
      end
      describe "with a padma_contact" do
        it "wont call contacts-ws" do
          pc = PadmaContact.new(id: padma_id, first_name: 'fn', last_name: 'ln')
          PadmaContact.should_not_receive(:find)
          Contact.get_by_padma_id(padma_id,account.id, pc)
        end
        it "caches padma_contact" do
          pc = PadmaContact.new(id: padma_id, first_name: 'fn', last_name: 'ln')
          expect{Contact.get_by_padma_id(padma_id,account.id, pc)}.to change{Contact.count}.by 1
        end
      end
      describe "witout a padma_contact" do
        it "fetches padma_contact from contacts-ws" do
          pc = PadmaContact.new(id: padma_id, first_name: 'fn', last_name: 'ln')
          PadmaContact.should_receive(:find).and_return(pc)
          Contact.get_by_padma_id(padma_id,account.id)
        end
        it "caches padma_contact" do
          pc = PadmaContact.new(id: padma_id, first_name: 'fn', last_name: 'ln')
          PadmaContact.should_receive(:find).and_return(pc)
          expect{Contact.get_by_padma_id(padma_id,account.id)}.to change{Contact.count}.by 1
        end
      end
      describe "with new_contact_attributes" do
        it "sets given attributes in created contact" do
          pc = PadmaContact.new(id: padma_id, first_name: 'fn', last_name: 'ln')
          PadmaContact.should_receive(:find).and_return(pc)
          Contact.get_by_padma_id(padma_id,account.id,nil,{external_id: 1})
          Contact.last.external_id.should == "1"
        end
      end
    end
  end
end
