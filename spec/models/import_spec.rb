require 'spec_helper'

describe Import do

  it { should belong_to :account }

  it "defaults status to ready" do
    i = build(:import, status: nil)
    i.save
    i.status.should == 'ready'
  end

end
