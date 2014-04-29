class StatsController < ApplicationController
  authorize_resource :contact

  # GET /stats
  def index
  	params[:stats] ||= {}
  	params[:distribution] ||= "instructor"

  	if params[:distribution] == "instructor"
  		builder_clazz = InstructorStatsSQLBuilder
  	else
  		builder_clazz = TimeSlotStatsSQLBuilder
  	end
    @stats = builder_clazz.new params[:stats].merge({:account => current_user.current_account})
    @contacts = Contact.find_by_sql(@stats.sql)
    @distribution = @stats.distribution
    @distribution_names = @stats.distribution_names
    respond_to do |format|
      format.html
      format.csv
    end
  end
end
