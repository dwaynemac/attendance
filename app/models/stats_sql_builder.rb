class StatsSQLBuilder

	attr_accessor :start_on, :end_on, :account, :include_cultural_activities

	DEFAULTS = {
		:include_cultural_activities => false,
		:start_on => Date.today.beginning_of_month,
		:end_on => Date.today.end_of_month
	}

	def initialize options = {}
		DEFAULTS.merge(options).each do |attr_name, value|
			self.send("#{attr_name}=", value)
		end	
	end

	def sql
	  %(
	  	SELECT *, #{time_slots_sum_select} FROM (
			SELECT contacts.*, #{time_slots_count_select nil}
			FROM contacts
			WHERE #{account_condition}
			GROUP BY contacts.id

			#{time_slot_queries}
		) AS attendance_distribution
		GROUP BY id
	  )
	end	

	def account_condition
		condition = ""
		if account.present?
			condition = "contacts.account_id = #{account.id}"
		end
		condition
	end

	def attendance_between_dates_condition
		"attendances.attendance_on BETWEEN '#{start_on}' AND '#{end_on}'"
	end

	def time_slot_queries
		query = ""

		time_slots.each do |time_slot|
			query << %(
				UNION

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

	def time_slots_count_select time_slot
		select = ""
		time_slots.each do |ts|
			if ts == time_slot
				ts_select = "count(*) as time_slot_#{ts.id}"
			else
				ts_select = "CAST(NULL AS INTEGER)  as time_slot_#{ts.id}"
			end

			ts_select << ", " unless ts == time_slots.last

			select << ts_select
		end
		select
	end

	def time_slots_sum_select
		select = ""
		total = ""
		time_slots.each do |ts|
			select << "SUM(time_slot_#{ts.id}) as sum_time_slot_#{ts.id}, "
			total << "time_slot_#{ts.id}"
			total << " + " unless ts == time_slots.last			
		end
		select << "SUM(#{total}) as attendance_total"
		select
	end

	def time_slots
		time_slots = []
		if include_cultural_activities
			time_slots = account.time_slots
		else
			time_slots = account.time_slots.where(:cultural_activity => false)
		end
		time_slots
	end
end