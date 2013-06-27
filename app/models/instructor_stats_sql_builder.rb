class InstructorStatsSQLBuilder

	attr_accessor :start_on, :end_on, :account, :include_cultural_activities

	DEFAULTS = {
		# include/exclude cultural activities from stats. excluded by default
		:include_cultural_activities => false,
		# start/end date. defaults to this month.
		:start_on => Date.today.beginning_of_month,
		:end_on => Date.today.end_of_month
	}

	def initialize options = {}
		# initialize builder using defaults
		DEFAULTS.merge(options).each do |attr_name, value|
			self.send("#{attr_name}=", value)
		end	
	end

	def sql
	  %(
	  	-- select contact attributes and stats
	  	SELECT id, account_id, padma_id, name, #{instructors_sum_select} FROM (
	  		-- select all contacts for that account
			SELECT contacts.*, #{instructors_count_select nil}
			FROM contacts
			WHERE #{account_condition}
			GROUP BY contacts.id

			-- unions for each instructor
			#{instructor_queries}
		) AS attendance_distribution
		GROUP BY id, account_id, padma_id, name
	  )
	end	

	# filters contacts by account_id
	def account_condition
		condition = ""
		if account.present?
			condition = "contacts.account_id = #{account.id}"
		end
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
				SELECT contacts.*, #{instructors_count_select username}
				FROM contacts
				INNER JOIN attendance_contacts ON contacts.id = attendance_contacts.contact_id
				INNER JOIN attendances ON attendance_contacts.attendance_id = attendances.id
				INNER JOIN time_slots ON attendances.time_slot_id = time_slots.id
				WHERE time_slots.padma_uid = '#{username.tr("_",".")}' 
				AND #{account_condition}
				AND #{attendance_between_dates_condition}
				#{cultural_activity_condition}
				GROUP BY contacts.id
			)
		end

		query	
	end

	# select count for the specified time slot and 0 otherwise
	def instructors_count_select username
		select = ""
		distribution.each do |u|
			if u == username
				u_select = "count(*) as #{username}"
			else
				u_select = "0 as #{u}"
			end

			u_select << ", " unless u.tr("_", ".") == account.usernames.last

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
			total << " + " unless username.tr("_",".") == account.usernames.last			
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
		account.usernames.collect {|username| username.tr(".", "_")}
	end
end