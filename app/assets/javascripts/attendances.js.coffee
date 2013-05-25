$(document).ready ->
	$('.add_attendance').click ->
		console.log($(this).attr('data-id'))
		false