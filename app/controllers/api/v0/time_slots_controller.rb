class Api::V0::TimeSlotsController < Api::V0::ApiController
  include Api::V0::TimeSlotsHelper
  respond_to :json
  
  authorize_resource
  
  before_filter :set_scope
  
  def index
    @time_slots = @scope.includes(:account).all
    respond_with({
      collection: api_json_for_collection(@time_slots),
      total: @time_slots.count
    })
  end
  
  private

  def set_scope
    @scope = TimeSlot.all
    if params[:account_name]
      @account = Account.find_by_name params[:account_name]
      if @account
        @scope = @scope.where(account_id: @account.id)
      else
        @scope = @scope.none
      end
    end
    # TODO filter by contact (for frequently assisted)
    # TODO filter by contact (for inscription in timeslot)
  end
end
