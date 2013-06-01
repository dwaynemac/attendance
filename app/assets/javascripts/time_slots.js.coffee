$(document).ready ->
	$(document).on 'click', '.delete_student', (event) ->
		$(this).parent().remove()
		false

	$($(document)).on 'click', '.add_student', (event) ->
		$(this).removeClass('add_student').addClass('delete_student')
		$(this).parent().prepend("<input type='hidden' value='" + $(this).attr('data-padma-id') + "' name='time_slot[padma_contacts][]'>")
		$('#time_slot_students').append($(this).parent())
		false

		