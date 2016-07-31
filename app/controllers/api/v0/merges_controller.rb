require 'merge'
class Api::V0::MergesController < Api::V0::ApiController

  def create
    son_id = params[:merge]['son_id']
    father_id = params[:merge]['father_id']

    m = Merge.new(son_id, father_id)
    m.merge

    render json: "OK", status: 201
  end

end
