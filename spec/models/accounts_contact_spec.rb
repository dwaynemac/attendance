require 'rails_helper'

describe AccountsContact do
  it { should belong_to(:contact) }
	
  it { should belong_to(:account) }

  it "validates uniqueness of [account,contact]" do
    ac = create(:accounts_contact)
    inv = build(:accounts_contact, account: ac.account, contact: ac.contact)
    expect(inv).to be_invalid
  end
  
end
