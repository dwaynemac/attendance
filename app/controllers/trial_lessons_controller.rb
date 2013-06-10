class TrialLessonsController < ApplicationController
  load_and_authorize_resource :through => :current_account, :except => [:new]

  # GET /trial_lessons
  def index
  end

  # GET /trial_lessons/1
  def show
  end

  # GET /trial_lessons/new
  def new
    @trial_lesson = current_account.trial_lessons.build
    @trial_lesson.attributes=params[:trial_lesson]
  end

  # GET /trial_lessons/1/edit
  def edit
  end

  # POST /trial_lessons
  def create
    if @trial_lesson.save
      redirect_to @trial_lesson, notice: 'Trial lesson was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /trial_lessons/1
  def update
    if @trial_lesson.update(params[:trial_lesson])
      redirect_to @trial_lesson, notice: 'Trial lesson was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /trial_lessons/1
  def destroy
    @trial_lesson.destroy
    redirect_to trial_lessons_url, notice: 'Trial lesson was successfully destroyed.'
  end
end
