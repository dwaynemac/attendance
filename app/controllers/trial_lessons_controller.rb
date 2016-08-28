class TrialLessonsController < ApplicationController
  load_and_authorize_resource :through => :current_account, :except => [:new, :create]

  # GET /trial_lessons
  def index
    @trial_lessons = @trial_lessons.includes(:time_slot, :contact).where(archived: false).order(trial_on: :desc)
  end

  # GET /trial_lessons/1
  def show
  end

  # GET /trial_lessons/new
  def new
    @trial_lesson = current_account.trial_lessons.build
    @trial_lesson.attributes=params[:trial_lesson]
    @initialize_select = get_initialize_select
  end

  # GET /trial_lessons/1/edit
  def edit
    @initialize_select = get_initialize_select
  end

  # POST /trial_lessons
  def create
    @trial_lesson = current_account.trial_lessons.build
    @trial_lesson.attributes = params[:trial_lesson]
    if @trial_lesson.save
      redirect_to @trial_lesson, notice: 'Trial lesson was successfully created.'
    else
      redirect_to new_trial_lesson_path, alert: "#{@trial_lesson.errors.full_messages.to_sentence}"
    end
  end

  # PATCH/PUT /trial_lessons/1
  def update
    if @trial_lesson.update(params[:trial_lesson])
      if params[:redirect_to].blank?
        redirect_to @trial_lesson, notice: 'Trial lesson was successfully updated.'
      elsif params[:redirect_to] == 'index'
        redirect_to trial_lessons_url, notice: 'Trial lesson was successfully archived.'
      end
    else
      render action: 'edit'
    end
  end

  # DELETE /trial_lessons/1
  def destroy
    @trial_lesson.destroy
    redirect_to trial_lessons_url, notice: 'Trial lesson was successfully destroyed.'
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

end
