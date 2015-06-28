require 'spec_helper'

describe Api::V0::TrialLessonsController do
  include TrialLessonsHelper
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
      let!(:ytrial){create(:trial_lesson, account: belgrano, contact_id: create(:contact).id)}
      let!(:ntrial){create(:trial_lesson, account: create(:account))}
      before do
        do_req account_name: 'belgrano'
      end
      it "returns trials of given account" do
        expect(response_trials_ids).to include ytrial.id
        expect(response_trials_ids).not_to include ntrial.id
      end

      describe "and contact_id" do
        before do
          PadmaContact.stub(:find).and_return PadmaContact.new id: 'the-id'
        end
        let!(:contact){ create(:contact, padma_id: 'the-id')}
        let!(:ctrial){create(:trial_lesson, account: belgrano, contact_id: contact.id)}
        before do
          do_req account_name: 'belgrano', contact_id: 'the-id'
        end
        it "returns trials with given contact padma_id" do
          expect(response_trials_ids).to include ctrial.id
          expect(response_trials_ids).not_to include ytrial.id
          expect(response_trials_ids).not_to include ntrial.id

          expect(response_trials.first).to include('contact_id', 'account_name')
        end
      end
    end
  end
end
