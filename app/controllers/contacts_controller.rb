class ContactsController < ApplicationController
  before_filter :find_contact_by_padma_id, :only => :show
  load_and_authorize_resource
  respond_to :html, :js

  def index
    if params[:time_slot_id].present?
      @time_slot = current_user.current_account.time_slots.find(params[:time_slot_id])
      @padma_contacts = @time_slot.recurrent_contacts
    elsif params[:padma_uid].present?
      @padma_contacts = PadmaContact.paginate(
                                            select: [:first_name, :last_name],
                                            where: {
                                              local_status: :student,
                                              local_teacher: params[:padma_uid]
                                            },
                                            sort: [:first_name, :asc],
                                            account_name: current_user.current_account.name,
                                            per_page: 1000)
    else
      @padma_contacts = current_user.current_account.students
    end
    respond_with @padma_contacts
  end

  def show
    @time_slots = @contact.time_slots.to_a
    @attendances_by_month = @contact.attendances.order("attendance_on DESC").group_by { |att| att.attendance_on.beginning_of_month }
  end

  private

  def find_contact_by_padma_id
    @contact = current_user.current_account.contacts.find_by_padma_id(params[:id])
  end

end
