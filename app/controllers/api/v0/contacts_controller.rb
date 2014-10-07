class Api::V0::ContactsController < Api::V0::ApiController

  before_filter :find_contact_by_padma_id

  respond_to :json

  def show
    contact_json = {
      time_slots: @contact.time_slots.map{|ts| {id: ts.id, name: ts.name, description: ts.description }}
    }
    respond_with contact_json
  end

  private


  def find_contact_by_padma_id
    @contact = Contact.includes(:time_slots).find_by_padma_id(params[:id])
  end

end
