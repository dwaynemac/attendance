class Api::V0::ImportsController < Api::V0::ApiController

  before_filter :get_account

  ##
  # @url /api/v0/imports
  # @action POST
  #
  # @required import[object] valid values: TimeSlot, Attendance
  # @required import[csv_file] CSV file
  # @required import[headers] 
  # @required import[account_name]
  #
  # @response_field id Import id
  #
  def create
    if @account
      scope = case params[:import][:object]
      when 'TimeSlot', 'Attendance'
        @account.send("#{params[:import][:object].underscore}_imports")
      else
        @account.imports
      end
      @import = scope.new(import_params)

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
    account_name = params[:import].delete(:account_name)
    @account = Account.find_by_name(account_name)
  end

  def import_params
    params.require(:import)
  end

end
