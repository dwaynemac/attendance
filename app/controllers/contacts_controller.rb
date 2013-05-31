class ContactsController < ApplicationController
  load_and_authorize_resource
  respond_to :js

  def index
    if params[:time_slot_id].present?
      @time_slot = current_user.current_account.time_slots.find(params[:time_slot_id])
      @padma_contacts = @time_slot.recurrent_contacts
    else params[:padma_uid].present?
      @padma_contacts = PadmaContact.paginate(where: {local_status: :student, local_teacher: params[:padma_uid]}, account_name: current_user.current_account.name, per_page: 1000)
    end
    respond_with @padma_contacts
  end  
end
