class InstructorStatsSQLBuilder
	attr_accessor :start_on, :end_on, :account, :include_cultural_activities, :include_former_students

	DEFAULTS = {
		# include/exclude cultural activities from stats. excluded by default
		:include_cultural_activities => false,
		:include_former_students => false,
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
			end
		end	
		options["include_cultural_activities"] = options["include_cultural_activities"] == '1' if options["include_cultural_activities"]
		options["include_former_students"] = options["include_former_students"] == '1' if options["include_former_students"]

		# initialize builder using defaults
		DEFAULTS.merge(options.symbolize_keys).each do |attr_name, value|
			self.send("#{attr_name}=", value)
		end	
	end

	def sql
	  %(
	  	-- select contact attributes and stats
	  	SELECT id, padma_id, name, MAX(status) status, #{instructors_sum_select} FROM (
	  		-- select all contacts for that account
			SELECT contacts.*, MAX(accounts_contacts.padma_status) status, #{instructors_count_select nil}
			FROM contacts
			INNER JOIN accounts_contacts ON contacts.id = accounts_contacts.contact_id
			WHERE #{account_condition}
			AND #{status_condition}
			GROUP BY contacts.id

			-- unions for each instructor
			#{instructor_queries}
		) AS attendance_distribution
		GROUP BY id, padma_id, name
		ORDER BY name ASC
	  )
	end	

	# filters contacts by account_id
	def account_condition
		condition = ""
		if account.present?
			condition = "accounts_contacts.account_id = #{account.id}"
		end
		condition
	end

  def status_condition
    condition = "( accounts_contacts.padma_status = 'student'"
    if include_former_students
      condition = "#{condition} OR accounts_contacts.padma_status = 'former_student'"
    end
    condition = "#{condition} )"
    condition
  end

	# filters attendances by start/end dates
	def attendance_between_dates_condition
		"attendances.attendance_on BETWEEN '#{start_on}' AND '#{end_on}'"
	end

	def cultural_activity_condition
		"AND time_slots.cultural_activity = 'f'" unless include_cultural_activities
	end	

	# unions for each instructor.
	def instructor_queries
		query = ""

		distribution.each do |username|
			query << %(
				UNION
				-- select contact attributes and count attendances on a time slot
				SELECT DISTINCT contacts.*, MAX(accounts_contacts.padma_status) status, #{instructors_count_select username}
				FROM contacts
				INNER JOIN accounts_contacts ON contacts.id = accounts_contacts.contact_id
				INNER JOIN attendance_contacts ON contacts.id = attendance_contacts.contact_id
				INNER JOIN attendances ON attendance_contacts.attendance_id = attendances.id
				INNER JOIN time_slots ON attendances.time_slot_id = time_slots.id
				WHERE attendances.username = '#{username.tr("_",".")}' 
				AND #{account_condition}
				AND #{attendance_between_dates_condition}
				AND #{status_condition}
				#{cultural_activity_condition}
				GROUP BY contacts.id
			)
		end

		query	
	end

	# select count for the specified instructor and 0 otherwise
	def instructors_count_select username
		select = ""
		distribution.each do |u|
			if u == username
				u_select = "COUNT(DISTINCT attendances.id) as #{username}"
			else
				u_select = "0 as #{u}"
			end

			u_select << ", " unless u.tr("_", ".") == distribution_names.last

			select << u_select
		end
		select
	end

	# sum time slot counts and calculate total.
	def instructors_sum_select
		select = ""
		total = ""
		distribution.each do |username|
			select << "SUM(#{username}) as sum_#{username}, "
			total << "#{username}"
			total << " + " unless username.tr("_",".") == distribution_names.last			
		end
		select << "SUM(#{total}) as attendance_total"
		select
	end

	# include/exclude cultural activities
	def time_slots
		time_slots = []
		if include_cultural_activities
			time_slots = account.time_slots
		else
			time_slots = account.time_slots.where(:cultural_activity => false)
		end
		time_slots
	end

	def distribution
		unless @distribution
			@distribution = account.usernames
		end

		@distribution.collect {|username| username.tr(".", "_")}
	end

	def distribution_names
		unless @distribution
			@distribution = account.usernames
		end

		@distribution
	end
end
