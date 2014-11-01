require 'spec_helper'

describe Account do
  let(:account){create(:account)}
  describe "#usernames" do
    context "if contacts-ws is online" do
      before do
        PadmaUser.stub(:paginate).and_return [
          PadmaUser.new( username: 'zoe'),
          PadmaUser.new( username: 'albert'),
          PadmaUser.new( username: 'dwayne')
        ]
      end
      it "are ordered alphabetically" do
        expect(account.usernames).to eq [
          'albert',
          'dwayne',
          'zoe'
        ]
      end
    end
  end
end
