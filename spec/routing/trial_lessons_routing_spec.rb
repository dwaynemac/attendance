require "spec_helper"

describe TrialLessonsController do
  describe "routing" do

    it "routes to #index" do
      get("/trial_lessons").should route_to("trial_lessons#index")
    end

    it "routes to #new" do
      get("/trial_lessons/new").should route_to("trial_lessons#new")
    end

    it "routes to #show" do
      get("/trial_lessons/1").should route_to("trial_lessons#show", :id => "1")
    end

    it "routes to #edit" do
      get("/trial_lessons/1/edit").should route_to("trial_lessons#edit", :id => "1")
    end

    it "routes to #create" do
      post("/trial_lessons").should route_to("trial_lessons#create")
    end

    it "routes to #update" do
      put("/trial_lessons/1").should route_to("trial_lessons#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/trial_lessons/1").should route_to("trial_lessons#destroy", :id => "1")
    end

  end
end
