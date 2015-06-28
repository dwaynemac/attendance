require 'spec_helper'

describe Api::V0::TrialLessonsController do
  describe "GET index" do
    let(:response_trials){ ActiveSupport::JSON.decode(response.body)['collection'] }
    let(:response_trials_ids){response_trials.map{|t| t['id'] }}
    def do_req(params={})
      get :index, params.merge!({app_key: ENV['app_key'], format: :json})
    end
    before do
      do_req
    end
    it { should respond_with 200 }
    describe "with account_name" do
      let!(:belgrano){ create(:account, name: 'belgrano')}
      let!(:ytrial){create(:trial_lesson, account: belgrano)}
      let!(:ntrial){create(:trial_lesson)}
      before do
        do_req account_name: 'belgrano'
      end
      it "returns trials of given account" do
        expect(response_trials_ids).to include ytrial.id
        expect(response_trials_ids).not_to include ntrial.id
      end
    end
  end
end
