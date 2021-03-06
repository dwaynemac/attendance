class TrialLessonsController < ApplicationController
  include TrialLessonsHelper
  
  load_and_authorize_resource :through => :current_account, :except => [:new, :create]

  # GET /trial_lessons
  def index
    set_ref_date
    
    @trial_lessons = @trial_lessons.includes(:time_slot, :contact).where(archived: false).order(trial_on: :desc)
  end

  # GET /trial_lessons/1
  def show
    unless @trial_lesson.time_slot.nil?
      redirect_to trial_lessons_path(ref_date: @trial_lesson.trial_on,
                                     open_time_slot_id: @trial_lesson.time_slot_id,
                                     open_trial_id: @trial_lesson.id
                                    )
    end
  end

  # GET /trial_lessons/new
  def new
    @trial_lesson = current_account.trial_lessons.build
    @trial_lesson.attributes = trial_lesson_params
    
    set_ref_date
    
    @time_slots = current_user.current_account.time_slots.order(:start_at)
    
    @initialize_select = get_initialize_select
  end

  # GET /trial_lessons/1/edit
  def edit
    @initialize_select = get_initialize_select
  end

  # POST /trial_lessons
  def create
    @trial_lesson = current_account.trial_lessons.build
    @trial_lesson.attributes = trial_lesson_params.to_h
    if @trial_lesson.save
      redirect_to @trial_lesson, notice: 'Trial lesson was successfully created.'
    else
      redirect_to new_trial_lesson_path, alert: "#{@trial_lesson.errors.full_messages.to_sentence}"
    end
  end

  # PATCH/PUT /trial_lessons/1
  def update
    if @trial_lesson.update(trial_lesson_params)
      if params[:redirect_to].blank?
        redirect_to trial_lessons_path(ref_date: @trial_lesson.trial_on), notice: 'Trial lesson was successfully updated.'
      elsif params[:redirect_to] == 'index'
        redirect_to trial_lessons_url, notice: 'Trial lesson was successfully archived.'
      end
    else
      render action: 'edit'
    end
  end

  # DELETE /trial_lessons/1
  def destroy
    ref_date = @trial_lesson.trial_on
    @trial_lesson.destroy
    redirect_to trial_lessons_url(ref_date: ref_date), notice: t('trial_lessons.destroy.success')
  end

  private

  def get_initialize_select
    if @trial_lesson.contact_id && !@trial_lesson.persisted? 
      {name: params[:padma_contact_name], id: params[:trial_lesson][:padma_contact_id]}
    elsif @trial_lesson.contact
      {name: "#{@trial_lesson.contact.name}", id: @trial_lesson.contact.padma_id}
    else
      {name: "", id: ""}
    end
  end
  
  def set_ref_date
    begin
      @ref_date = Date.parse params[:ref_date]
    rescue
      @ref_date = Time.zone.today
    end
    if @ref_date.nil?
      @ref_date = Time.zone.today
    end
  end

  def trial_lesson_params
    if params.has_key?(:trial_lesson) && !params[:trial_lesson].blank?
      params.require(:trial_lesson).permit(
          :trial_on,
          :time_slot_id,
          :padma_uid,
          :padma_contact_id,
          :assisted,
          :confirmed,
          :archived,
          :absence_reason
      )
    else
      {}
    end
  end
end
