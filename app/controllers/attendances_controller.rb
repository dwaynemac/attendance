class AttendancesController < ApplicationController
  load_and_authorize_resource
  respond_to :html

  def index
    @time_slots = current_user.current_account.time_slots
    respond_with @attendances
  end

  def new
    @padma_contacts = @attendance.time_slot.recurrent_contacts
    respond_with @attendance
  end

  def edit
    @padma_contacts = @attendance.time_slot.recurrent_contacts
    respond_with @attendance
  end
  
  def show
    respond_with @attendance
  end

  def create
    @attendance.account = current_user.current_account
    @attendance.save
    @padma_contacts = @attendance.time_slot.recurrent_contacts
    respond_with @attendance
  end

  def update
    @attendance.update(params[:attendance])
    respond_with @attendance
  end

  def destroy
    @attendance.destroy
    respond_with @attendance
  end
  
end
