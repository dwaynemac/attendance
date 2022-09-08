class Api::V0::StatsController < Api::V0::ApiController

  def show
    @account = Account.find_by_name params[:account_name]
    @stats = InstructorStatsSQLBuilder.new params[:stats].merge({account: @account})
    @contacts = Contact.find_by_sql(@stats.sql)

    if @stats.include_former_students
      @contacts.reject!{|c| c.status == 'former_student' && c.attendance_total == 0 }
    end

    ret = {}
    @contacts.each do |c|
      ret[c.padma_id] = {}
      ret[c.padma_id]["total"] = c.attendance_total.to_i
      @stats.distribution.each do |u|
        ret[c.padma_id][u[:username]] = c.send("sum_#{u[:sql_username]}")/c.attendance_total
      end
    end

    render json: ret

  end

end
