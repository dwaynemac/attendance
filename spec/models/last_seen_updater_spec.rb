require 'spec_helper'

describe LastSeenUpdater do
  let(:account) {create(:account)}
  let(:contact) {create(:contact)}
  let(:attendance) {create(:attendance)}
  
  before do
    allow(PadmaContact).to receive(:paginate) do
      [contact]
    end
    #Contact.any_instance.stub(:padma_contact).and_return(PadmaContact.new(first_name: 'fn', last_name: 'ln'))
    allow(PadmaAccount).to receive(:find) do
      account
    end
  end

  
  describe "when updating an account" do
    it "should call PadmaContact to update the last_seen_at status" do
      attendance.attendance_contacts.create(contact_id: contact.id)
      expect_any_instance_of(Contact).to receive(:padma_contact).and_return(PadmaContact.new)
      expect_any_instance_of(PadmaContact).to receive(:update).with(hash_including(:contact))
      LastSeenUpdater.update_account(account.name)
    end
  end
end
