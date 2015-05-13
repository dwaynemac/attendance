$(document).ready ->

  $("#padma_contacts_select").trigger("change")
  
  $("#attendance_time_slot_id").on 'change', (event) ->
    alert 'a'
    if($("#padma_contacts_select").val() == "recurrent_contacts")
      $("#padma_contacts_select").trigger("change")
