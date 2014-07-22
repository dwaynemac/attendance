require 'spec_helper'

describe StatsController do
  before (:each) do
    sign_in_as_a_valid_user
  end
  describe "GET /stats" do
    it "responds 200" do
      get :index
      should respond_with 200
    end
  end
end
