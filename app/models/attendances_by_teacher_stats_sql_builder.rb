class AttendancesByTeacherStatsSQLBuilder
	attr_accessor :start_on, :end_on, :account, :include_cultural_activities, :include_former_students, :include_former_teachers

	DEFAULTS = {
		# include/exclude cultural activities from stats. excluded by default
		:include_cultural_activities => true,
		:include_former_teachers => false,
		# start/end date. defaults to this month.
		:start_on => Date.today.beginning_of_month,
		:end_on => Date.today.end_of_month
	}

	def initialize options = {}
		# prepare date and boolean params
		["start_on", "end_on"].each do |multipart_attr_name|
			if options["#{multipart_attr_name}(3i)"]
				options[multipart_attr_name] = Date.new(options.delete("#{multipart_attr_name}(1i)").to_i,
														options.delete("#{multipart_attr_name}(2i)").to_i,
														options.delete("#{multipart_attr_name}(3i)").to_i)
      elsif options[multipart_attr_name].is_a?(String)
        options[multipart_attr_name] = options[multipart_attr_name].to_date
			end
		end
		options["include_cultural_activities"] = options["include_cultural_activities"] == '1' if options["include_cultural_activities"]
		options["include_former_teachers"] = options["include_former_teachers"] == '1' if options["include_former_teachers"]

		# initialize builder using defaults
		DEFAULTS.merge(options.symbolize_keys).each do |attr_name, value|
			self.send("#{attr_name}=", value)
		end
	end

	def result_hash
		scope = Attendance.where(account_id: account.id)
		scope = scope.where(suspended: [false, nil])
		unless include_cultural_activities
			scope = scope.joins(:time_slot).where(time_slots: {cultural_activity: [false, nil]})
		end
		scope = scope.where("attendance_on between ? and ?", start_on, end_on)
		scope.group(:username).count
	end

end
