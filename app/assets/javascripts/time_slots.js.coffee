$(document).ready ->
	$(document).on 'click', '#time_slot_padma_contacts .add', (event) ->
		$(this).removeClass('add').addClass('delete')
		$(this).parent().prepend("<input type='hidden' value='" + $(this).attr('data-padma-id') + "' name='time_slot[padma_contacts][]'>")
		$('ul#time_slot_students').append($(this).parent())
		false

		