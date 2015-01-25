class Api::V0::ContactsController < Api::V0::ApiController

  respond_to :json

  def show
    @contact = Contact.includes(:time_slots).find_by_padma_id(params[:id])
    contact_json = {
      time_slots: @contact.time_slots.map{|ts| {id: ts.id, name: ts.name, description: ts.description }}
    }
    respond_with contact_json
  end

  def last_trial
    contact = Contact.find_by_padma_id(params[:id])
    if contact.nil?
      render json: 'not found', status: 404
    else
      scope = contact.trial_lessons
      if params[:account_name]
        scope = scope.joins(:account)
                     .where(accounts: { name: params[:account_name]})
      end

      @trial_lesson = scope.order('trial_on DESC').first
      if @trial_lesson
        respond_with({ trial_lesson: { id: @trial_lesson.id, trial_on: @trial_lesson.trial_on }})
      else
        respond_with({ trial_lesson: nil})
      end
    end
  end
end
