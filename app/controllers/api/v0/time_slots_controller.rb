class Api::V0::TimeSlotsController < Api::V0::ApiController
  include Api::V0::TimeSlotsHelper
  respond_to :json
  
  authorize_resource
  
  before_filter :set_scope
  
  # @param account_name filters TimeSlots by account
  # @param include_recurrent_contacts
  def index
    @scope = @scope.where(params[:where])
    @time_slots = @scope.includes(:account, :contacts).all
    render json: {
      collection: api_json_for_collection(@time_slots,
        { include_recurrent_contacts: params[:include_recurrent_contacts] }
      ),
      total: @time_slots.count
    }
  end
  
  def show
    @time_slot = TimeSlot.find(params[:id])
    render json: api_json(
      @time_slot,
      {include_recurrent_contacts: params[:include_recurrent_contacts]}
    )
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
