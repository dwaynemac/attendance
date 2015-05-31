class AttendancesController < ApplicationController
  load_and_authorize_resource
  respond_to :html

  def index
    days_from = params[:days_from] || 0
    days_to = params[:days_to] || 7
    further_limit = days_to.to_i
    closer_limit = days_from.to_i
    @view_range = (closer_limit..further_limit)
    @attendances = @attendances.where(attendance_on: (further_limit.days.ago.to_date..closer_limit.days.ago.to_date))

    @time_slots = current_user.current_account.time_slots.order("start_at ASC")
    @time_slots_wout_day = current_user.current_account.time_slots.without_schedule

    respond_with @attendances
  end

  def new
    @time_slot = @attendance.time_slot
    unless @time_slot.nil?
      @padma_contacts = @time_slot.recurrent_contacts
      @trial_lessons = TrialLesson.where(time_slot_id: @attendance.time_slot_id, trial_on: @attendance.attendance_on)
    end
    respond_with @attendance
  end

  def edit
    @padma_contacts = @attendance.time_slot.recurrent_contacts
    @trial_lessons = TrialLesson.where(time_slot_id: @attendance.time_slot_id, trial_on: @attendance.attendance_on)
    respond_with @attendance
  end
  
  def show
    @trial_lessons = @attendance.trial_lessons
    respond_with @attendance
  end

  def create
    update_trial_lessons params[:trial_lessons] if params[:trial_lessons]
    @attendance.account = current_user.current_account
    @attendance.save
    @padma_contacts = @attendance.time_slot.recurrent_contacts
    redirect_to attendances_url
  end

  def update
    update_trial_lessons params[:trial_lessons] if params[:trial_lessons]
    @attendance.update(params[:attendance])
    redirect_to attendances_url
  end

  def destroy
    @attendance.destroy
    respond_with @attendance
  end
  
  private
  
  def update_trial_lessons trial_lesson_ids
    trial_lesson_ids.each do |id|
      tl = TrialLesson.where(:account_id => current_user.current_account.id).find(id)
      tl.update_attribute(:assisted, true)
    end
  end

end
