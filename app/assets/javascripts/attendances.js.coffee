$(document).ready ->
	$(document).on 'click', '#attendance_padma_contacts .add', (event) ->
		$(this).removeClass('add').addClass('delete')
		$(this).parent().prepend("<input type='hidden' value='" + $(this).attr('data-padma-id') + "' name='attendance[padma_contacts][]'>")
		$('ul#attendance_contacts').append($(this).parent())
		false
  
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
