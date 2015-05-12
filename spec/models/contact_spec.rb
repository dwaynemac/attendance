require 'spec_helper'

describe Contact do
  it { have_many(:accounts).through(:accounts_contact) }

  let(:account){ create(:account)}

  describe ".students_on(account)" do
    before do
      create(:contact).accounts_contacts.create(account_id: account.id,
                                                padma_status: 'student')
      create(:contact).accounts_contacts.create(account_id: account.id,
                                                padma_status: 'prospect')
      create(:contact).accounts_contacts.create(account_id: create(:account).id,
                                                padma_status: 'student')
    end
    it "scopes to students on given account" do
      expect(Contact.students_on(account).count).to eq 1
    end
  end

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

  describe "sync_from_contacts_ws" do
    let(:padma_id){'contact-id'}
    let(:contact){create(:contact, padma_id: padma_id)}
    before do
      create(:accounts_contact, contact: contact,
                                account: account,
                                padma_status: 'former_student')
    end
    describe "if padma_contact given" do
      let(:padma_contact){PadmaContact.new(pc_attributes)}
      describe "if it has local_statuses" do
        let(:pc_attributes){{first_name: 'new-first-name',
                             last_name: 'new-last-name',
                             local_statuses: [
          {account_name: account.name, local_status: 'student'},
          {account_name: 'account-2', local_status: 'former_student'}
        ]}}
        it "wont call contacts-ws" do
          PadmaContact.should_not_receive(:find)
          contact.sync_from_contacts_ws(padma_contact)
        end
        it "updates accounts_contacts statuses" do
          contact.sync_from_contacts_ws(padma_contact)
          ac = contact.accounts_contacts
                      .where(account_id: account.id)
                      .first
          expect(ac.padma_status).to eq 'student'
        end
        it "created missing accounts_contacts" do
          expect{contact.sync_from_contacts_ws(padma_contact)}.to change{AccountsContact.count}.by 1
        end
        it "updates contact name" do
          contact.sync_from_contacts_ws(padma_contact)
          contact.reload
          expect(contact.name).to eq 'new-first-name new-last-name'
        end
      end
      describe "if it doesnt have local_statuses" do
        let(:pc_attributes){{first_name: 'a'}}
        it "fetches padma_contact from contacts-ws" do
          PadmaContact.should_receive(:find)
          contact.sync_from_contacts_ws(padma_contact)
        end
      end
    end
    describe "if padma_contact not given" do
      let(:padma_contact){nil}
      it "fetches padma_contact from contacts-ws" do
        PadmaContact.should_receive(:find)
        contact.sync_from_contacts_ws(padma_contact)
      end
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
