class StatsController < ApplicationController
  authorize_resource :contact

  before_action :set_defaults, only: [:index] 

  # GET /stats
  def index
  	if params[:distribution] == "instructor"
  		builder_clazz = InstructorStatsSQLBuilder
  	else
  		builder_clazz = TimeSlotStatsSQLBuilder
  	end
    @stats = builder_clazz.new stats_attributes
    @contacts = Contact.find_by_sql(@stats.sql)

    if @stats.include_former_students
      @contacts.reject!{|c| c.status == 'former_student' && c.attendance_total == 0 }
    end
    @teachers = CrmLegacyContact.search ids: @contacts.map(&:padma_id),
      select: [:local_teacher],
      account_name: current_user.current_account.name

    @distribution = @stats.distribution
    @distribution_names = @stats.distribution_names
    respond_to do |format|
      format.html
      format.csv do
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = 'attachment; filename="stats.csv"'
      end
    end
  end

  def attendances_by_teacher
    @stats = AttendancesByTeacherStatsSQLBuilder.new stats_attributes
    respond_to do |format|
      format.html
      format.csv do
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = 'attachment; filename="attendances_by_teacher.csv"'
      end
    end
  end

  private

  # default params[:stats] = {}
  # default distribution = instructor
  # default period = current_month
  def set_defaults
  	params[:stats] ||= {}
    if params[:stats] == {}
      params[:easy_period] ||= :current_month
    end

  	params[:distribution] ||= "instructor"
  end

  def stats_attributes
    s = (params[:stats]||{}).merge({:account => current_account})
    case params[:easy_period].try(:to_sym)
      when :current_month
        s.delete_if{|k,_| k =~ /start_on|end_on/ }.merge(start_on: Date.today.beginning_of_month, end_on: Date.today.end_of_month)
      when :last_month
        s.delete_if{|k,_| k =~ /start_on|end_on/ }.merge(start_on: 1.month.ago.beginning_of_month.to_date, end_on: 1.month.ago.end_of_month.to_date)
      else
        s
    end
  end
end
