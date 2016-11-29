require 'spec_helper'

describe Api::V0::TimeSlotsController do
  describe "GET index" do
    let(:response_collection){ ActiveSupport::JSON.decode(response.body)['collection'] }
    def do_req(params={})
      get :index, params.merge!({app_key: ENV['app_key'], format: :json})
    end
    before do
      do_req
    end
    it { should respond_with 200 }
    
    describe "with :account_name" do
      let!(:my_acc){ create(:account, name: 'my_acc') }
      let!(:my_timeslot){ create(:time_slot, account: my_acc) }
      let!(:not_my_timeslot){ create(:time_slot) }
      before do
        do_req(account_name: my_acc.name)
      end
      it "returns timeslots of given account" do
        expect(response_collection.map{|i| i['id']}).to include my_timeslot.id
      end
      it "wont return timeslots of other accounts" do
        expect(response_collection.map{|i| i['id']}).not_to include not_my_timeslot.id
      end
    end
  end
end
