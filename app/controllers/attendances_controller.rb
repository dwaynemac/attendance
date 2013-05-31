class AttendancesController < ApplicationController
  load_and_authorize_resource
  respond_to :html

  def index
    @time_slots = current_user.current_account.time_slots
    respond_with @attendances
  end

  def new
    @padma_contacts = @attendance.time_slot.recurrent_contacts
    @trial_lessons = TrialLesson.where(time_slot_id: @attendance.time_slot_id, trial_on: @attendance.attendance_on)
    respond_with @attendance
  end

  def edit
    @padma_contacts = @attendance.time_slot.recurrent_contacts
    @trial_lessons = TrialLesson.where(time_slot_id: @attendance.time_slot_id, trial_on: @attendance.attendance_on)
    respond_with @attendance
  end
  
  def show
    @trial_lessons = TrialLesson.where(time_slot_id: @attendance.time_slot_id, trial_on: @attendance.attendance_on)
    respond_with @attendance
  end

  def create
    update_trial_lessons params[:trial_lessons] if params[:trial_lessons]
    @attendance.account = current_user.current_account
    @attendance.save
    @padma_contacts = @attendance.time_slot.recurrent_contacts
    respond_with @attendance
  end

  def update
    update_trial_lessons params[:trial_lessons] if params[:trial_lessons]
    @attendance.update(params[:attendance])
    respond_with @attendance
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
