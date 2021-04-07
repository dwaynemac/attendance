class AttendancesController < ApplicationController
  before_action :load_attendance, only: [:create, :update, :new]
  load_and_authorize_resource

  def index
    @day_span = 7

    @days_from = params[:days_from] || 0
    @days_to = params[:days_to] || @day_span
    further_limit = @days_to.to_i
    closer_limit = @days_from.to_i
    @view_range = (further_limit - 1).downto(closer_limit)
    @attendances = @attendances.where(attendance_on: (further_limit.days.ago.to_date..closer_limit.days.ago.to_date))

    @time_slots = current_user.current_account.time_slots.reorder(:start_at)

    unless params[:username].nil?
      cookies[:filter_attendances_by_username] = params[:username]
    end
    @username = params[:username] || cookies[:filter_attendances_by_username]

    @time_slots = @time_slots.where(padma_uid: @username) if @username.present?
    @only_pending = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:only_pending])
    @time_slots_wout_day = current_user.current_account.time_slots.without_schedule

    @recent = nil # disable until bug #107776460 fixed
    # @recent = get_recent_time_slot
    
    respond_to do |format|
      format.html
    end
  end

  def new
    @remote_form = true
    @back_w_params = params.select{|k,v| k.in?(%W(days_to days_from only_pending username))}
    @time_slot = @attendance.time_slot
    unless @time_slot.nil?
      @attendance.username = @time_slot.padma_uid # default attendance teacher to timeslot teacher
      @padma_contacts = @time_slot.recurrent_contacts
      @trial_lessons = TrialLesson.where(time_slot_id: @attendance.time_slot_id, trial_on: @attendance.attendance_on)
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
    @remote_form = true
    @padma_contacts = @attendance.time_slot.recurrent_contacts
    @trial_lessons = TrialLesson.where(time_slot_id: @attendance.time_slot_id, trial_on: @attendance.attendance_on)
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def show
    @trial_lessons = @attendance.trial_lessons

    respond_to do |format|
      format.html
    end
  end

  def create
    back_w_params = ActiveSupport::JSON.decode(params[:redirect_back_w_params]) if params[:redirect_back_w_params]
    update_trial_lessons @attendance, params[:trial_lessons], :create
    
    if @attendance.save
      @padma_contacts = @attendance.time_slot.recurrent_contacts
      respond_to do |format|
        format.html { redirect_to attendances_url(back_w_params) }
        format.js { render 'update' }
      end
    else
      respond_to do |format|
        flash.now[:alert] = "#{clean_errors(@attendance.errors)}"
        format.js { render 'update' }
      end
    end
  end

  def update
    update_trial_lessons @attendance, params[:trial_lessons], :update
    if @attendance.update(attendance_params_for_update)
      respond_to do |format|
       format.html { redirect_to attendances_url }
       format.json { render json: {id: @attendance.id, message: "updated"}, status: 201 }
       format.js
      end
    else
      respond_to do |format|
        flash.now[:alert] = "#{clean_errors(@attendance.errors)}"
        format.js { render 'update' }
      end
    end
  end

  def destroy
    update_trial_lessons @attendance, params[:trial_lessons], :destroy
    contacts = @attendance.contacts.map(&:id)
    account = @attendance.account
    @attendance.destroy
    Contact.find(contacts).map{|c| c.update_last_seen_at(account)}

    redirect_to attendances_path
  end
  
  private

  def attendance_params_for_update
    permitted_params = attendance_params
    if params[:attendance] && params[:attendance][:padma_contacts].nil?
      permitted_params = permitted_params.merge!({padma_contacts: []})
    end
    permitted_params
  end

  def get_recent_time_slot
    recent = current_user.current_account.time_slots # Get all account timeslots
	    .where(padma_uid: current_user.username) # for current user
	    .where("#{Time.now.strftime('%A').downcase}".to_sym => true) # That ocurr today
	    .select {|t|
	      # Select those that already started 
	      Time.zone.local(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, t.start_at.hour, t.start_at.min) <= Time.zone.now and
	      # And that finished (or not) 1/2 hour ago
	      Time.zone.now <= (Time.zone.local(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, t.end_at.hour, t.end_at.min) + 30.minutes)
    }.last # Get the last one

    # If there is an attendance already set for the recent timeslot dont show it
    if recent.present?
      if Attendance.where(time_slot_id: recent.id, attendance_on: Time.zone.today).exists?
        nil
      else
        recent
      end
    end
  end
  
  def update_trial_lessons attendance, trial_lesson_ids, action

    unless trial_lesson_ids.nil?
      trial_lesson_ids.each do |id|
        tl = TrialLesson.where(:account_id => current_user.current_account.id).find(id)
        tl.inform_activity_stream(action, I18n.locale, true)
        tl.update_attribute(:assisted, true)
      end
    end

    unless attendance.trial_lessons.empty?
      not_attended = attendance.trial_lessons.pluck(:id) - ( trial_lesson_ids.try(:map,&:to_i) || [] )
      not_attended.each do |id|
        tl = TrialLesson.where(:account_id => current_user.current_account.id).find(id)
        tl.inform_activity_stream(action, I18n.locale, false)
      end
    end
  end

  def clean_errors(error_hash)
    e = ""
    error_hash.each do |k,v|
      e << "," unless e.blank?
      e << "#{k}: #{v}"
    end
    e
  end

  def load_attendance
    if params.has_key?(:id)
      @attendance = Attendance.find(params[:id])
      @attendance.account_id = current_user.current_account.id
    else
      @attendance = Attendance.new(attendance_params)
      @attendance.account_id = current_user.current_account.id
    end
  end

  def attendance_params
    params.require(:attendance).permit(
        :account_id,
        :time_slot_id,
        :attendance_on,
        :username,
        :suspended,
        :padma_contacts => []
    )
  end

end
