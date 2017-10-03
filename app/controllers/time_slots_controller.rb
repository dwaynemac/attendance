class TimeSlotsController < ApplicationController

  before_filter :update_timeslot_params, only: [:create, :update]
  load_and_authorize_resource 

  def index
    @time_slots = @time_slots
  end

  def show
    @students = @time_slot.contacts.students_on(current_user.current_account)
    @regular_participants = @time_slot.recurrent_contacts
    @attendances_by_month = @time_slot.attendances
                                      .where("attendance_on > ?",3.months.ago)
                                      .order('attendance_on DESC')
                                      .group_by { |att| att.attendance_on.beginning_of_month }
    respond_to do |format|
      format.html
      format.json { render json: @time_slot }
    end
  end

  def vacancies
    @time_slots = @time_slots.where(cultural_activity: false)
  end

  def new
  end

  def edit
  end  
  
  def create
    @time_slot.account = current_user.current_account
    if @time_slot.save
      redirect_to @time_slot, notice: 'Time slot was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    @time_slot.account = current_user.current_account
    
    respond_to do |format|
      if @time_slot.update(params[:time_slot])
        format.html {
          redirect_to @time_slot, notice: 'Time slot was successfully updated.'
	}
	format.json { render json: { success: true }}
      else
	format.html {
          render action: 'edit'
	}
	format.json {
          render json: @time_slot.errors, status: :unprocessable_entity
	}
      end
    end
  end

  def destroy
    # @time_slot initialized by load_and_authorize_resource
    # @time_slot.destroy
    @time_slot.update_attribute(:deleted, true)
    redirect_to time_slots_url, notice: t('time_slots.destroy.success')
  end	
  
  private

  def update_timeslot_params
    selected_day_names = params[:dayname] ? params[:dayname].map{|day| day.downcase} : []
    params.delete :dayname
    Date::DAYNAMES.each do |day_name|
      day_name = day_name.downcase
      params[:time_slot][day_name.to_sym] = (selected_day_names.include? day_name) ? "1" : "0"
    end
  end 

end
