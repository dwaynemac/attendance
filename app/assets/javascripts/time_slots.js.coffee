$(document).ready ->
	$(document).on 'click', '#time_slot_padma_contacts .add', (event) ->
		$(this).removeClass('add').addClass('delete')
		$(this).parent().prepend("<input type='hidden' value='" + $(this).attr('data-padma-id') + "' name='time_slot[padma_contacts][]'>")
		$('ul#time_slot_students').append($(this).parent())
		false

$ ->
  timeFormat = (value) ->
    hours = Math.floor(value / 60)
    minutes = value - (hours * 60)
    hours = "0" + hours  if hours.toString().length is 1
    minutes = "0" + minutes  if minutes.toString().length is 1
    hours: hours
    minutes: minutes
  
  default_start_hour = $("#time_slot_start_at_4i").val()
  default_start_minute = $("#time_slot_start_at_5i").val()
  default_start_at = parseInt(default_start_hour) * 60 + parseInt(default_start_minute)

  default_end_hour = $("#time_slot_end_at_4i").val()
  default_end_minute = $("#time_slot_end_at_5i").val()
  default_end_at = parseInt(default_end_hour) * 60 + parseInt(default_end_minute)

  $("#amount").text default_start_hour + ":" + default_start_minute + " To " + default_end_hour + ":" + default_end_minute

  $("#slider").slider
    range: true
    min: 0
    max: 1439
    step: 1
    values: [
      default_start_at
      default_end_at
    ]
    slide: (e, ui) ->
      startTime = timeFormat(ui.values[0])
      startHour = startTime.hours
      startMinute = startTime.minutes
      endTime = timeFormat(ui.values[1])
      endHour = endTime.hours
      endMinute = endTime.minutes
      $("#amount").text startHour + ":" + startMinute + " To " + endHour + ":" + endMinute
      return

    stop: (event, ui) ->
      startTime = timeFormat(ui.values[0])
      startHour = startTime.hours
      startMinute = startTime.minutes
      endTime = timeFormat(ui.values[1])
      endHour = endTime.hours
      endMinute = endTime.minutes
      $("#time_slot_start_at_4i").val startHour
      $("#time_slot_start_at_5i").val startMinute
      $("#time_slot_end_at_4i").val endHour
      $("#time_slot_end_at_5i").val endMinute
  
  
  $(".selectpicker").selectpicker()
  
  $("#time_slot_cultural_activity").bootstrapSwitch();

  $('.multiselect').multiselect({
    includeSelectAllOption: true
  });

		