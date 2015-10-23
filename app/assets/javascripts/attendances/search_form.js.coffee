$(document).ready ->
  $("form#filter-attendances input, form#filter-attendances select").change ->
    $("#filter-attendance-button").show()
