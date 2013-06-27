class TimeSlotStatsSQLBuilder

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
	  	SELECT id, account_id, padma_id, name, #{time_slots_sum_select} FROM (

	  		-- select all contacts for that account
			SELECT contacts.*, #{time_slots_count_select nil}
			FROM contacts
			WHERE #{account_condition}
			GROUP BY contacts.id

			-- unions for each time slot
			#{time_slot_queries}
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

	# unions for each time slot.
	def time_slot_queries
		query = ""

		time_slots.each do |time_slot|
			query << %(
				UNION

				-- select contact attributes and count attendances on a time slot
				SELECT contacts.*, #{time_slots_count_select time_slot}
				FROM contacts
				INNER JOIN attendance_contacts ON contacts.id = attendance_contacts.contact_id
				INNER JOIN attendances ON attendance_contacts.attendance_id = attendances.id
				WHERE attendances.time_slot_id = #{time_slot.id} 
				AND #{account_condition}
				AND #{attendance_between_dates_condition}
				GROUP BY contacts.id
			)
		end

		query	
	end

	# select count for the specified time slot and 0 otherwise
	def time_slots_count_select time_slot
		select = ""
		distribution.each do |ts|
			if time_slot && ts == "ts_#{time_slot.name.tr(" ","").underscore}"
				ts_select = "count(*) as #{ts}"
			else
				ts_select = "0 as #{ts}"
			end

			ts_select << ", " unless ts == "ts_#{time_slots.last.name.tr(" ","").underscore}"

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
			total << " + " unless ts == "ts_#{time_slots.last.name.tr(" ","").underscore}"
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
		time_slots.collect {|ts| "ts_#{ts.name.tr(" ","").underscore}"}
	end
end