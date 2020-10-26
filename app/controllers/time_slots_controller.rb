class TimeSlotsController < ApplicationController

  before_filter :load_time_slot, only: [:create, :update]
  before_filter :update_timeslot_params, only: [:create, :update]
  load_and_authorize_resource

  def index
    @unscheduled_time_slots = @time_slots.where(unscheduled: true)
    @time_slots = @time_slots.with_schedule
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
    if @time_slot.save
      redirect_to @time_slot, notice: 'Time slot was successfully created.'
    else
      render action: 'new'
    end
  end

  def update    
    respond_to do |format|
      if @time_slot.update(time_slot_params)
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

  def time_slot_params
    if params.has_key?(:time_slot) && !params[:time_slot].blank?
      params.require(:time_slot).permit(
        :padma_uid,
        :name,
        :start_at,
        :end_at,
        :monday,
        :tuesday,
        :wednesday,
        :thursday,
        :friday,
        :saturday,
        :sunday,
        :cultural_activity,
        :external_id,
        :unscheduled,
        :padma_contacts => []
      )
    else
      {}
    end
  end

  def load_time_slot
    if params.has_key?(:id)
      @time_slot = TimeSlot.find(params[:id])
      @time_slot.account = current_user.current_account
    else
      @time_slot = TimeSlot.new(time_slot_params)
      @time_slot.account = current_user.current_account
    end
  end

  def update_timeslot_params
    permitted_params = time_slot_params
    selected_day_names = params[:dayname] ? params[:dayname].map{|day| day.downcase} : []
    permitted_params.delete(:dayname)
    Date::DAYNAMES.each do |day_name|
      day_name = day_name.downcase
      # params[:time_slot][day_name.to_sym] = (selected_day_names.include? day_name) ? "1" : "0"
      permitted_params[day_name.to_sym] = (selected_day_names.include? day_name) ? "1" : "0"
    end
  end 

end
