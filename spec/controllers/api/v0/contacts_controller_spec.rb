require 'spec_helper'

describe Api::V0::ContactsController do
  describe "GET /api/v0/contacts" do
    let(:time_slot){create(:time_slot)}
    let(:contact){create(:contact, padma_id: 'padma-contact-id')}

    before do
      create(:contact_time_slot, contact: contact, time_slot: time_slot)
    end

    context "with format: :json" do
      let(:format){:json}

      before do
        get :show, app_key: ENV['app_key'],
                   id: 'padma-contact-id',
                   format: format
      end

      it { should respond_with 200 }
      
      describe "json" do
        let(:json){ActiveSupport::JSON.decode(response.body)}
        it "includes timeslots" do
          expect(json['time_slots'].first['id']).to eq time_slot.id
        end
      end
    end
    
  end
end
