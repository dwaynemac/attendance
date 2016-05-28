class TimeSlotStatsSQLBuilder

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
			Rails.logger.debug "#{attr_name} = #{value}"
			self.send("#{attr_name}=", value)
		end	
	end

	def sql
	  %(
	  	-- select contact attributes and stats
	  	SELECT id, padma_id, name, status, #{time_slots_sum_select} FROM (

	  		-- select all contacts for that account
			SELECT contacts.*, MAX(accounts_contacts.padma_status) status, #{time_slots_count_select nil}
			FROM contacts
			INNER JOIN accounts_contacts ON contacts.id = accounts_contacts.contact_id
			WHERE #{account_condition}
			AND #{status_condition}
			GROUP BY contacts.id

			-- unions for each time slot
			#{time_slot_queries}
		) AS attendance_distribution
		GROUP BY id, padma_id, name
		ORDER BY name ASC
	  )
	end	

  def status_condition
    condition = "( accounts_contacts.padma_status = 'student'"
    if include_former_students
      condition = "#{condition} OR accounts_contacts.padma_status = 'former_student'"
    end
    condition = "#{condition} )"
    condition
  end

	# filters contacts by account_id
	def account_condition
		condition = ""
		if account.present?
			condition = "accounts_contacts.account_id = #{account.id}"
		end
		condition
	end

	# filters attendances by start/end dates
	def attendance_between_dates_condition
		"attendances.attendance_on BETWEEN '#{start_on}' AND '#{end_on}'"
	end

	# unions for each time slot.
	def time_slot_queries
		query = ""

		time_slots.each do |time_slot|
			query << %(
				UNION

				-- select contact attributes and count attendances on a time slot
				SELECT contacts.*, accounts_contacts.padma_status status, #{time_slots_count_select time_slot}
				FROM contacts
				INNER JOIN accounts_contacts ON contacts.id = accounts_contacts.contact_id
				INNER JOIN attendance_contacts ON contacts.id = attendance_contacts.contact_id
				INNER JOIN attendances ON attendance_contacts.attendance_id = attendances.id
				WHERE attendances.time_slot_id = #{time_slot.id} 
				AND #{account_condition}
				AND #{attendance_between_dates_condition}
				AND #{status_condition}
				GROUP BY contacts.id
			)
		end

		query	
	end

	# select count for the specified time slot and 0 otherwise
	def time_slots_count_select time_slot
		select = ""
		distribution.each do |ts|
			if time_slot && ts == "ts_#{time_slot.id}"
				ts_select = "count(*) as #{ts}"
			else
				ts_select = "0 as #{ts}"
			end

			ts_select << ", " unless ts == "ts_#{time_slots.last.id}"

			select << ts_select
		end
		select
	end

	# sum time slot counts and calculate total.
	def time_slots_sum_select
		select = ""
		total = ""
		distribution.each do |ts|
			select << "SUM(#{ts}) as sum_#{ts}, "
			total << ts
			total << " + " unless ts == "ts_#{time_slots.last.id}"
		end
		select << "SUM(#{total}) as attendance_total"
		select
	end

	# include/exclude cultural activities
	def time_slots
		return @time_slots if @time_slots

		if include_cultural_activities
			@time_slots = account.time_slots
		else
			@time_slots = account.time_slots.where(:cultural_activity => false)
		end
		@time_slots
	end

	def distribution
		time_slots.collect {|ts| "ts_#{ts.id}"}
	end

	def distribution_names
		time_slots.collect {|ts| ts.name}
	end

  private

  def normalize_text(str)
    str.gsub(/[^0-9A-Za-z]/,"")
  end
end
