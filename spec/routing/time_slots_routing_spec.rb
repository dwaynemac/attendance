require "spec_helper"

describe TimeSlotsController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/time_slots")).to route_to("time_slots#index")
    end

    it "routes to #new" do
      expect(get("/time_slots/new")).to route_to("time_slots#new")
    end

    it "routes to #show" do
      expect(get("/time_slots/1")).to route_to("time_slots#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/time_slots/1/edit")).to route_to("time_slots#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/time_slots")).to route_to("time_slots#create")
    end

    it "routes to #update" do
      expect(put("/time_slots/1")).to route_to("time_slots#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/time_slots/1")).to route_to("time_slots#destroy", :id => "1")
    end

  end
end
