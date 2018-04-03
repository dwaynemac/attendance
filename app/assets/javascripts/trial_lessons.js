/* global Stimulus */
/* global $ */
(() => {
  const application = Stimulus.Application.start();
  
  application.register("trial_selector", class extends Stimulus.Controller {
    
    static get targets() {
      return ["timeSlotId", "trialOn", "option"];
    }
    
    connect(){
      console.log("connected");
    }
    
    selectOption(event){
      var time_slot_id = $(event.currentTarget).data('time-slot-id')
      var date = $(event.currentTarget).data('trial-on')
      
      this.data.set("time_slot_id", time_slot_id)
      this.data.set("trial_on", date)
      
      this.highlightSelectedOption(event)
      this.updateHiddenFields()
      
      event.preventDefault()
    }
    
    highlightSelectedOption(event){
      $(".selected").toggleClass("selected")
      $(event.currentTarget).parents(".list-group-item").toggleClass("selected")
    }
    
    updateHiddenFields(){
      this.timeSlotIdTarget.value = this.data.get("time_slot_id")
      this.trialOnTarget.value = this.data.get("trial_on")
    }

  });
    
})();


/*

$(document).ready ->
  console.log 'here'
  $(".selectTrialDate").click (e) ->
    time_slot_id = $(this).data('time-slot-id')
    date = $(this).data('date')
    year = date.match(/(\d{4})-/)[1]
    month = date.match(/-(\d{2})-/)[1]
    day = date.match(/-(\d{2})/)[1]
    
    
    $('#trial_lesson_time_slot_id').val(time_slot_id)
    $("#trial_lesson_trial_on_3i").val(day)
    $("#trial_lesson_trial_on_2i").val(month)
    $("#trial_lesson_trial_on_1i").val(year)
    e.preventDefault()
       
*/