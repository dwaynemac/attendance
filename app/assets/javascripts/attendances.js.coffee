$(document).ready ->
	$(document).on 'click', '.delete_attendance', (event) ->
		$(this).parent().remove()
		false

	$($(document)).on 'click', '.add_attendance', (event) ->
		$(this).removeClass('add_attendance').addClass('delete_attendance')
		$(this).parent().prepend("<input type='hidden' value='" + $(this).attr('data-padma-id') + "' name='attendance[padma_contacts][]'>")
		$('#attendance_contacts').append($(this).parent())
		false

		