require 'spec_helper'

describe Api::V0::ImportsController do
  before do
    unless @belgrano = Account.find_by_name('belgrano')
      @belgrano = create(:account, name: 'belgrano') 
    end
  end

  def post_req
    post :create, import: { file: 'x',
                            headers: 'x',
                            account_name: 'belgrano'
    }
  end
  
  describe "#create" do

    it "requires a valid app_key"

    it "should return status 201" do
      post_req
      should respond_with 201
    end

    it "create an import instance" do
      expect{ post_req }.to change{Import.count}.by 1
    end

    describe "created import" do
      before { post_req }
      subject{ assigns(:import)  }
      its(:account){ should == @belgrano }
    end

    it "return import instance id" do
      response = post_req
      hash = ActiveSupport::JSON.decode response.body
      hash[:id] = Import.last.id
    end

    it "should get account" do
      post_req
      assigns(:account).name.should == 'belgrano'
    end
  end

end
