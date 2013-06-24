class StatsController < ApplicationController
  authorize_resource :contact

  # GET /stats
  def index
    sql_builder = StatsSQLBuilder.new :account => current_user.current_account
    @contacts = Contact.find_by_sql(sql_builder.sql)
    @time_slots = sql_builder.time_slots
  end
end
