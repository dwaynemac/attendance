require 'spec_helper'

describe LastSeenUpdater do
  let(:account) {create(:account)}
  let(:contact) {create(:contact)}
  let(:attendance) {create(:attendance)}
  
  before do
    PadmaContact.stub(:paginate) do
      [contact]
    end
    #Contact.any_instance.stub(:padma_contact).and_return(PadmaContact.new(first_name: 'fn', last_name: 'ln'))
    PadmaAccount.stub(:find) do
      account
    end
  end

  
  describe "when updating an account" do
    it "should call PadmaContact to update the last_seen_at status" do
      attendance.attendance_contacts.create(contact_id: contact.id)
      Contact.any_instance.should_receive(:padma_contact).and_return(PadmaContact.new)
      PadmaContact.any_instance.should_receive(:update).with(hash_including(:contact))
      LastSeenUpdater.update_account(account.name)
    end
  end
end