$(document).ready ->
  console.log 'here'
  $(".selectTrialDate").click (e) ->
    time_slot_id = $(this).data('time-slot-id')
    date = $(this).data('date')
    year = date.match(/(\d{4})-/)[1]
    month = date.match(/-(\d{2})-/)[1]
    day = date.match(/-(\d{2})/)[1]
    
    $(".selected").toggleClass("selected")
    $(this).parents(".list-group-item").toggleClass("selected")
    
    $('#trial_lesson_time_slot_id').val(time_slot_id)
    $("#trial_lesson_trial_on_3i").val(day)
    $("#trial_lesson_trial_on_2i").val(month)
    $("#trial_lesson_trial_on_1i").val(year)
    e.preventDefault()
       