$(document).ready ->
	$(document).on 'click', '#attendance_padma_contacts .add', (event) ->
		$(this).removeClass('add').addClass('delete')
		$(this).parent().prepend("<input type='hidden' value='" + $(this).attr('data-padma-id') + "' name='attendance[padma_contacts][]'>")
		$('ul#attendance_contacts').append($(this).parent())
		false

		