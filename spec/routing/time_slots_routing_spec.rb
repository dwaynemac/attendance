require "spec_helper"

describe TimeSlotsController do
  describe "routing" do

    it "routes to #index" do
      get("/time_slots").should route_to("time_slots#index")
    end

    it "routes to #new" do
      get("/time_slots/new").should route_to("time_slots#new")
    end

    it "routes to #show" do
      get("/time_slots/1").should route_to("time_slots#show", :id => "1")
    end

    it "routes to #edit" do
      get("/time_slots/1/edit").should route_to("time_slots#edit", :id => "1")
    end

    it "routes to #create" do
      post("/time_slots").should route_to("time_slots#create")
    end

    it "routes to #update" do
      put("/time_slots/1").should route_to("time_slots#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/time_slots/1").should route_to("time_slots#destroy", :id => "1")
    end

  end
end
