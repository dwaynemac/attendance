class AttendancesController < ApplicationController
  load_and_authorize_resource
  respond_to :json
  respond_to :html, :only => [:index]

  def index
    respond_with @attendances
  end

  def new
    respond_with @attendance
  end
  
  def show
    respond_with @attendance
  end

  def create
    @attendance.save
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
