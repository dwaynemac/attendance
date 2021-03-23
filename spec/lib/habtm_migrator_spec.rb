require 'rails_helper'
require 'habtm_migrator'

describe HabtmMigrator do

  before do
    Contact.delete_all
  end

  describe "#migrate_contact(contact)" do
    let(:account){create(:account)}
    let(:migrator){HabtmMigrator.new(account)}
    describe "if contact has no account_id" do
      let(:contact){Contact.create(padma_status: 'student')}
      it "wont create a AccountContact" do
        expect{migrator.migrate_contact(contact)}.not_to change{AccountsContact.count}
      end
      it "wont nullify contact.padma_status" do
        migrator.migrate_contact(contact)
        expect(contact.reload.padma_status).to eq 'student'
      end
    end
    describe "if contact is already linked with account through AccountsContact" do
      let(:contact){Contact.last}
      before do
        c = Contact.new
        c.padma_status = 'student'
        c.account_id = account.id
        c.save!
        AccountsContact.create!(contact_id: c.id, account_id: account.id)
      end
      it "wont create a AccountContact" do
        expect{migrator.migrate_contact(contact)}.not_to change{AccountsContact.count}
      end
      it "nullifies contact.account_id" do
        migrator.migrate_contact(contact)
        expect(contact.reload.account_id).to be_nil
      end
      it "nullifies contact.padma_status" do
        migrator.migrate_contact(contact)
        expect(contact.reload.padma_status).to be_nil
      end
    end
    describe "if contact is linked with OTHER account through AccountsContacts" do
      let(:other_account){create(:account)}
      let(:contact){Contact.last}
      before do
        c = Contact.new
        c.padma_status = 'student'
        c.account_id = account.id
        c.save!
        AccountsContact.create!(contact_id: c.id, account_id: other_account.id)
      end
      it "creates a AccountContact" do
        expect{migrator.migrate_contact(contact)}.to change{AccountsContact.count}.by 1
      end
      it "sets account_id and contact_id in created AccountsContact linking contact and account" do
        migrator.migrate_contact(contact)
        ac = AccountsContact.last
        expect(ac.contact_id).to eq contact.id
        expect(ac.account_id).to eq account.id
      end
      it "nullifies contact.account_id" do
        migrator.migrate_contact(contact)
        expect(contact.reload.account_id).to be_nil
      end
      it "set padma_status in created AccountContact" do
        migrator.migrate_contact(contact)
        ac = AccountsContact.last
        expect(ac.padma_status).to eq 'student'
      end
      it "nullifies contact.padma_status" do
        migrator.migrate_contact(contact)
        expect(contact.reload.padma_status).to be_nil
      end
    end
    describe "if contact has no AccountsContact linked" do
      let(:contact){Contact.last}
      before do
        c = Contact.new
        c.padma_status = 'student'
        c.account_id = account.id
        c.save!
      end
      it "creates a AccountContact" do
        expect{migrator.migrate_contact(contact)}.to change{AccountsContact.count}.by 1
      end
      it "sets account_id and contact_id in created AccountsContact linking contact and account" do
        migrator.migrate_contact(contact)
        ac = AccountsContact.last
        expect(ac.contact_id).to eq contact.id
        expect(ac.account_id).to eq account.id
      end
      it "nullifies contact.account_id" do
        migrator.migrate_contact(contact)
        expect(contact.reload.account_id).to be_nil
      end
      it "set padma_status in created AccountContact" do
        migrator.migrate_contact(contact)
        ac = AccountsContact.last
        expect(ac.padma_status).to eq 'student'
      end
      it "nullifies contact.padma_status" do
        migrator.migrate_contact(contact)
        expect(contact.reload.padma_status).to be_nil
      end
    end
  end
end
