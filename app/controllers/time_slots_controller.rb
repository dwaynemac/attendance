class TimeSlotsController < ApplicationController
  load_and_authorize_resource

  def index
  end

  def new
  end
  
  def create
    # @time_slot initialized by load_and_authorize_resource
    # @time_slot.update_attribute("account_id", current_user.current_account.id)
    if @time_slot.save
      redirect_to @time_slot, notice: 'Time slot was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    # @time_slot initialized by load_and_authorize_resource
    if @time_slot.update(params[:time_slot])
      redirect_to @time_slot, notice: 'Time slot was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    # @time_slot initialized by load_and_authorize_resource
    @time_slot.destroy
    redirect_to time_slots_url, notice: 'Time slot was successfully destroyed.'
  end	
end
