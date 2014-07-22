@showCustomMenu = () ->
  $("#stats-custom-period select").prop('disabled',false)
  $("#stats-easy-period").hide()
  $("#stats-custom-period").show()
  return false


