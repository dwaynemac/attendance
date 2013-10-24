require 'spec_helper'

describe Import do

  let(:csv_file) do
    extend ActionDispatch::TestProcess
    fixture_file_upload("/files/belgrano_horarios.csv","text/csv")
  end

  it { should belong_to :account }

  it "defaults status to ready" do
    i = build(:import, status: nil)
    i.save
    i.status.should == 'ready'
  end

  it "saves CSV file" do
    i = build(:import, csv_file: csv_file)
    i.save!
    i.csv_file.identifier.should == 'belgrano_horarios.csv'
  end

  describe "#index_for" do
    it "returns index of given string in headers" do
      i = create(:time_slot_import, headers: [nil, 'name', 'observations'])
      i.index_for('name').should == 1
      i.index_for('observations').should == 2
    end
  end

  describe "#account_name=" do
    it "linkt to local account with given name" do
      i = build(:import,account: nil,  account_name: 'belgrano') # account: nil to avoid FactoryGirl to set account
      i.save!
      i.account.name.should == 'belgrano'
    end
  end


end
