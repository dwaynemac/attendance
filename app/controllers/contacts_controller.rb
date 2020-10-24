class ContactsController < ApplicationController
  before_filter :find_contact_by_padma_id, :only => :show
  load_and_authorize_resource
  # respond_to :html, :js, :csv

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

    # TODO removed respond_with method as it is no longer included in rails
    # and compatible gem is for Rails 4.1.2
    #
    # check if it is responding correctly for JS and if
    # CSV response is needed
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    @contact.update_attributes(params.require( :contact ))

    respond_to do |format|
      format.json do
        render json: {
          id: @contact.id,
          time_slots: @contact.time_slots
                              .order(:start_at)
                              .where(account_id: current_user.current_account.id)
                              .map{|ts| {id: ts.id,
                                         name: ts.name,
                                         description: ts.description }}
        }
      end
    end
  end

  def show
    @time_slots = @contact.time_slots
                          .order(:start_at)
                          .where(account_id: current_user.current_account.id)
    @attendances_by_month = @contact.attendances.order("attendance_on DESC").group_by { |att| att.attendance_on.beginning_of_month }
  end

  private

  def find_contact_by_padma_id
    @contact = Contact.get_by_padma_id(params[:id],current_user.current_account.id)
  end

end
