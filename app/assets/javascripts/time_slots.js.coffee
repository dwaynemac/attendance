$(document).ready ->

  $("input#timeslots-filter").quickfilter("table#timeslots tbody tr")

	$(document).on 'click', '#time_slot_padma_contacts .add', (event) ->
		$(this).removeClass('add').addClass('delete')
		$(this).parent().prepend("<input type='hidden' value='" + $(this).attr('data-padma-id') + "' name='time_slot[padma_contacts][]'>")
		$('ul#time_slot_students').append($(this).parent())
		false

$ ->
  $(".selectpicker").selectpicker()
  
  $("#time_slot_cultural_activity").bootstrapSwitch({
    onText: "Yes",
    offText: "No"
  })

  $("#time_slot_unscheduled").bootstrapSwitch({
    onText: "Yes",
    offText: "No"
  })

  $('.multiselect').multiselect({
    includeSelectAllOption: true
  })
  
  $("#loading").hide()
  $(document).ajaxStart ->
    $("#loading").show()
  
  $(document).ajaxComplete ->
    $("#loading").hide()

@checkVacancies = (e) ->
  td = $(e).parent()
  $(e).hide()
  td.children('#vacancies-think').show()
  setTimeout ->
    td.html(td.data('text'))
  , 5000
  , td
