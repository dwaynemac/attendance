require 'spec_helper'

describe TimeSlotImport do

  let(:csv_file) do
    extend ActionDispatch::TestProcess
    fixture_file_upload("/files/belgrano_horarios.csv","text/csv")
  end

  describe "#process_CSV" do
    it "creates a TimeSlot for every valid row"
    it "stores imported rows ids"
    it "stores failed rows numbers"
  end

  describe "only accepts VALID_HEADERS" do
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
