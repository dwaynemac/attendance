class Api::V0::ImportsController < Api::V0::ApiController

  before_filter :get_account

  ##
  # @url /api/v0/imports
  # @action POST
  #
  # @required import[object] valid values: TimeSlot, Attendance
  # @required import[file] CSV file
  # @required import[headers] 
  # @required import[account_name]
  #
  # @response_field id Import id
  #
  def create
    if @account
      @import = @account.imports.new
      if @import.save
        render json: { id: @import.id }, status: 201
      else
        render json: { error: 'couldnt create import'}, status: 400
      end
    else
      render json: { error: 'no account with this account_name'}, status: 400
    end
  end

  private

  def get_account
    @account = Account.find_by_name(params[:import][:account_name])
  end

end
