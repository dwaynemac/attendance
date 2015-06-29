# @restful_api v0
class Api::V0::TrialLessonsController < Api::V0::ApiController

  include TrialLessonsHelper

  respond_to :json

  authorize_resource

  before_filter :set_scope

  # @url /api/v0/trial_lessons
  # @action GET
  #
  # Scope Options
  # @optional [String] account_name will scope this account
  # @optional [String] contact_id will scope to contact with given padma_id
  # @optional [Hash] where
  #                  eg: * trial_on_lt: '2015-1-1'
  #                      * updated_at_gte: '2014-1-1'
  def index
    @trial_lessons = @scope.api_where(params[:filters]).includes(:account, :contact)
    respond_with( {
      collection: api_json_for_collection(@trial_lessons),
      total: @trial_lessons.count
    })
  end

  private

  def set_scope
    @scope = TrialLesson.all
    if params[:account_name]
      @account = Account.find_by_name params[:account_name]
      if @account
        @scope = @scope.where(account_id: @account.id)
      else
        @scope = @scope.none
      end
    end
    if params[:contact_id]
      @contact = Contact.find_by_padma_id(params[:contact_id])
      if @contact
        @scope = @scope.where(contact_id: @contact.id)
      else
        @scope = @scope.none
      end
    end
  end

end
