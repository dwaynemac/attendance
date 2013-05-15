require 'spec_helper'

describe Contact do
  it "should require an account" do
    build(:contact, :account => nil).should_not be_valid
  end	
end
