class InstructorStatsSQLBuilder
	attr_accessor :start_on, :end_on, :account, :include_cultural_activities, :include_former_students, :include_former_teachers

	DEFAULTS = {
		# include/exclude cultural activities from stats. excluded by default
		:include_cultural_activities => false,
		:include_former_students => false,
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
		options["include_former_students"] = options["include_former_students"] == '1' if options["include_former_students"]
		options["include_former_teachers"] = options["include_former_teachers"] == '1' if options["include_former_teachers"]

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

		distribution.each do |user|
			query << %(
				UNION
				-- select contact attributes and count attendances on a time slot
				SELECT DISTINCT contacts.*, MAX(accounts_contacts.padma_status) status, #{instructors_count_select user[:sql_username]}
				FROM contacts
				INNER JOIN accounts_contacts ON contacts.id = accounts_contacts.contact_id
				INNER JOIN attendance_contacts ON contacts.id = attendance_contacts.contact_id
				INNER JOIN attendances ON attendance_contacts.attendance_id = attendances.id
				INNER JOIN time_slots ON attendances.time_slot_id = time_slots.id
				WHERE attendances.username = '#{user[:username]}'
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
	def instructors_count_select sql_username
		select = ""
		distribution.each do |u|
			if u == sql_username
				u_select = "COUNT(DISTINCT attendances.id) as #{sql_username}"
			else
				u_select = "0 as #{u[:sql_username]}"
			end

			u_select << ", " unless u[:username] == distribution_names.last

			select << u_select
		end
		select
	end

	# sum time slot counts and calculate total.
	def instructors_sum_select
		select = ""
		total = ""
		distribution.each do |user|
			select << "SUM(#{user[:sql_username]}) as sum_#{user[:sql_username]}, "
			total << "#{user[:sql_username]}"
			total << " + " unless user[:username] == distribution_names.last
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

  # ids (in this case they are usernames)
	def distribution
    if @distribution.nil?
      if include_former_teachers
        @distribution = account.attendances.where("attendance_on between ? and ?", start_on, end_on)
                               .group(:username)
                               .pluck(:username)
                               .compact
                               .map{|username| {username: username, sql_username: sql_username(username)}}
        if @distribution.empty?
          # 0 attendances case
          @distribution = account.usernames.map{|username| {username: username, sql_username: sql_username(username)}}
        end
      else
        @distribution = account.usernames.map{|username| {username: username, sql_username: sql_username(username)}}
      end
    end

    # quick patch until code refactored to consider @ in usernames
    # quick patch possible because in theory @ users are not teachers.
    # if @distribution
    #   @distribution = @distribution.reject{ |username| username =~ /@/ }
    # end


		@distribution #.collect {|username| username.tr(".", "_").tr("@","$")}
	end

  # usernames (in this case they are usernames)
	def distribution_names
		unless @distribution
			@distribution = account.usernames.map{|username| {username: username, sql_username: sql_username(username)}}
		end

    @distribution.map{|u| u[:username]}.compact
	end

  def sql_username(username)
    "_#{Digest::MD5.hexdigest(username)}"
  end
end
