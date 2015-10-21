$(document).ready ->
  $(document).on 'click', '.delete', (event) ->
    $(this).parent().remove()
    if($('#attendance_contacts li').length == 0)
      $('.modal-footer .btn-danger').show()
      $('.modal-footer .btn-primary').hide()
      false

  $(document).on 'change', '#attendance_time_slot_id', (event) ->
    $("#padma_contacts_select").trigger("change")
