require "spec_helper"

describe TrialLessonsController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/trial_lessons")).to route_to("trial_lessons#index")
    end

    it "routes to #new" do
      expect(get("/trial_lessons/new")).to route_to("trial_lessons#new")
    end

    it "routes to #show" do
      expect(get("/trial_lessons/1")).to route_to("trial_lessons#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/trial_lessons/1/edit")).to route_to("trial_lessons#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/trial_lessons")).to route_to("trial_lessons#create")
    end

    it "routes to #update" do
      expect(put("/trial_lessons/1")).to route_to("trial_lessons#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/trial_lessons/1")).to route_to("trial_lessons#destroy", :id => "1")
    end

  end
end
