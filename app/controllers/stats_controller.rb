class StatsController < ApplicationController
  authorize_resource :contact

  # GET /stats
  def index
  	distribution = params.delete(:distribution)
  	if distribution == "instructor"
  		builder_clazz = InstructorStatsSQLBuilder
  	else
  		builder_clazz = TimeSlotStatsSQLBuilder
  	end	
    sql_builder = builder_clazz.new :account => current_user.current_account, :include_cultural_activities => params[:include_cultural_activities]
    @contacts = Contact.find_by_sql(sql_builder.sql)
    @distribution = sql_builder.distribution
  end
end
