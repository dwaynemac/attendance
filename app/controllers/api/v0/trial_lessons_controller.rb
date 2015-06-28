# @restful_api v0
class Api::V0::TrialLessonsController < Api::V0::ApiController

  respond_to :json

  authorize_resource

  before_filter :load_account
  before_filter :load_contact
  before_filter :load_trials

  # @url /api/v0/trial_lessons
  # @action GET
  #
  # @required [String] account_name will scope this account
  # @optional [String] contact_id will scope to contact with given padma_id
  # @optional [Hash] where This conditions are forwarded to ActiveRecord :where
  def index
    @trial_lessons.where(params[:where])
    respond_with( {
      collection: @trial_lessons,
      total: @trial_lessons.count
    })
  end

  private

  def load_account
    if params[:account_name]
      @account = Account.find_by_name params[:account_name]
    end
  end

  def load_contact
    if @account && params[:contact_id]
      @contact = Contact.get_by_padma_id(params[:contact_id])
      @contact = Contact.get_by_padma_id(params[:id],@account.id)
    end
  end

  def load_trials
    @trial_lessons = TrialLesson.scoped
    if @account
      @trial_lessons = @account.trial_lessons 
    end
    if @contact
      @trial_lessons = @contact.trial_lessons 
    end
  end
end
