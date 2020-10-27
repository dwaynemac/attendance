require 'rails_helper'

describe Import do

  let(:csv_file) do
    extend ActionDispatch::TestProcess
    fixture_file_upload("/files/belgrano_horarios.csv","text/csv")
  end


  let(:import){create(:import, csv_file: csv_file)}

  it { should belong_to :account }
  it { should validate_presence_of :account }
  it { should have_many :imported_ids }
  it { should have_many :failed_rows } 

  it "defaults status to ready" do
    i = build(:import, status: nil)
    i.save
    expect(i.status).to eq :ready
  end

  it "saves CSV file" do
    i = build(:import, csv_file: csv_file)
    i.save!
    expect(i.csv_file.identifier).to eq 'belgrano_horarios.csv'
  end

  describe "#process_CSV" do
    describe "if handle_row raises and exception" do
      before { allow_any_instance_of(Import).to receive(:handle_row).and_raise 'error raised by handle_row' }
      it "adds row as failed_row and continues" do
        expect{import.process_CSV}.to change{import.failed_rows.count}.by 26
      end
      it "wont raise exception" do
        expect{import.process_CSV}.not_to raise_exception
      end
    end
  end

  describe "#index_for" do
    it "returns index of given string in headers" do
      i = create(:time_slot_import, headers: [nil, 'name', 'observations'])
      expect(i.index_for('name')).to eq 1
      expect(i.index_for('observations')).to eq 2
    end
  end

  describe "#account_name=" do
    it "link to local account with given name" do
      i = build(:import,account: nil,  account_name: 'belgrano') # account: nil to avoid FactoryBot to set account
      i.save!
      expect(i.account.name).to eq 'belgrano'
    end
  end
end
