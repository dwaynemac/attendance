$(document).ready ->
  $("form#filter-attendances input, form#filter-attendances select").change ->
    $("#filter-attendance-button").show()

  # When TimeSlot is selected we set teacher as timeslot's teacher
  $(document).on 'change', '#attendance_time_slot_id', (event) ->
    $.getJSON('/time_slots/'+$('#attendance_time_slot_id').val(),(json,response) ->
      $("#attendance_username").val(json.padma_uid)
    )
