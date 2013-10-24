require 'spec_helper'

describe TimeSlotImport do

  let(:headers){ [nil, name] }

  let(:csv_file) do
    extend ActionDispatch::TestProcess
    fixture_file_upload("/files/belgrano_horarios.csv","text/csv")
  end

  describe "#process_CSV" do
    it "wont run if status is not :ready"
    it "creates a TimeSlot for every valid row" do
      create(:import, csv_file: csv_file)
    end
    it "stores imported rows ids"
    it "stores failed rows numbers"
    it "sets status to :finished"
  end

  describe "only accepts VALID_HEADERS" do
    it "accepts nil" do
      i = TimeSlotImport.new(headers: [nil, 'name'])
      i.valid?
      i.errors[:headers].should be_empty
    end
    it "accepts :name" do
      i = TimeSlotImport.new(headers: ['name'])
      i.valid?
      i.errors[:headers].should be_empty
    end
    it "reject :some_other" do
      i = TimeSlotImport.new(headers: ['some_other_header'])
      i.valid?
      i.errors[:headers].should_not be_empty
    end
  end
end
