$(document).ready ->
	$(document).on 'click', '.delete', (event) ->
		$(this).parent().remove()
		false

	$(document).on 'change', '#padma_contacts_select', (event) ->
		if($(this).val() == 'recurrent_contacts')
			$.ajax(url:'/contacts',
             data: {time_slot_id: $('#attendance_time_slot_id').val()},
             dataType: "script")
		else if($(this).val() == 'all_students')
			$.ajax(url:'/contacts',
             dataType: "script")
		else
			$.ajax(url:'/contacts',
             data: {padma_uid: $(this).val()},
             dataType: "script")
