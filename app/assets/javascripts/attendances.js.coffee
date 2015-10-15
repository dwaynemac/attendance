$(document).ready ->

  $('#uninitialized_new_attendance').click ->
    registerEvent('registered-uninitialized-attendance')
    return true # follow link

  $('.initialized_attendance').click ->
    registerEvent('registered-initialized-attendance')
    return true # follow link

  $('.empty_attendance').click ->
    registerEvent('registered-empty-attendance')
    return true # follow link
  
  $(document).on 'click', '#attendance_padma_contacts .add', (event) ->
    $('.modal-footer .btn-danger').hide()
    $('.modal-footer .btn-primary').show()
    $(this).removeClass('add').addClass('delete')
    $(this).parent().prepend("<input type='hidden' value='" + $(this).attr('data-padma-id') + "' name='attendance[padma_contacts][]'>")
    $('ul#attendance_contacts').append($(this).parent())
    $(this).parents('.modal-footer .btn-danger').hide()
    $(this).parents('.modal-footer .btn-primary').show()
    false
        
  $(document).on 'click', '#toggle-hidden-timeslots', (event) ->
    event.preventDefault()
    registerEvent('showed-hidden-timeslots')
    $('#toggle-hidden-timeslots').toggleClass('active')
    $('.today.other-users-ts').toggle()

$ ->
  $("#loader").hide()
  $(document).ajaxStart ->
    $("#loader").show()
    $('.selectpicker').attr('disabled', true).selectpicker('refresh');
    
  $(document).ajaxComplete ->
    $("#loader").hide()
    $('.selectpicker').attr('disabled', false).selectpicker('refresh');
    
    
  $(".selectpicker").selectpicker()
  $(".datepicker").datepicker()

  $(".trial_lessons").each (index, check_box_obj) -> 
    $("#"+check_box_obj.id).bootstrapSwitch({
      onText: "Yes",
      offText: "No",
    })

  $(".ignore_unscheduled").click (e)->
    e.preventDefault()
    warning_entry = $(this).parent()
    $.ajax
      type: 'PUT'
      data: { time_slot: {unscheduled: true}}
      url: $(this).attr('href')
      dataType: 'json'
      success: (data, textStatus, jqXHR) ->
        warning_entry.remove()

