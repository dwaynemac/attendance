class Api::V0::ContactsController < Api::V0::ApiController

  before_filter :find_contact_by_padma_id

  respond_to :json


  def show
    respond_with @contact
  end

  private


  def find_contact_by_padma_id
    @contact = Contact.find_by_padma_id(params[:id])
  end

end
