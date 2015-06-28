require 'spec_helper'

describe Api::V0::TrialLessonsController do
  describe "GET index" do
    def do_req(params={})
      get :index, params.merge!({app_key: ENV['app_key'], format: :json})
    end
    before do
      do_req
    end
    it { should respond_with 200 }
  end
end
