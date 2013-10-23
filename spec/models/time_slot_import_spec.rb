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
end
