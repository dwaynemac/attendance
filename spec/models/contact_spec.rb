require 'spec_helper'

describe Contact do
  it "should require an account" do
    build(:contact, :account => nil).should_not be_valid
  end	

  let(:account){ Account.first || create(:account)}

  describe ".get_by_padma_id" do
    let(:padma_id){'contact-id'}
    describe "if already cached" do
      before do
        @contact = Contact.find_by_padma_id(padma_id) || create(:contact, padma_id: padma_id, account_id: account.id)
      end
      it "finds local_contact with given padma_id" do
        Contact.get_by_padma_id(padma_id,account.id).should == @contact
      end
      it "wont create a new contact" do
        expect{Contact.get_by_padma_id(padma_id,account.id)}.not_to change{Contact.count}
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
    end
  end
end
