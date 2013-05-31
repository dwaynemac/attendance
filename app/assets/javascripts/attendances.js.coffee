$(document).ready ->
	$(document).on 'change', '#padma_contacts_select', (event) ->
		if($(this).val() == 'recurrent_contacts')
			$.ajax(url:'/contacts', data: {time_slot_id: $('#attendance_time_slot_id').val()}, dataType: "script")
		else
			$.ajax(url:'/contacts', data: {padma_uid: $(this).val()}, dataType: "script")

	$(document).on 'click', '.delete_attendance', (event) ->
		$(this).parent().remove()
		false

	$($(document)).on 'click', '.add_attendance', (event) ->
		$(this).removeClass('add_attendance').addClass('delete_attendance')
		$(this).parent().prepend("<input type='hidden' value='" + $(this).attr('data-padma-id') + "' name='attendance[padma_contacts][]'>")
		$('#attendance_contacts').append($(this).parent())
		false

		