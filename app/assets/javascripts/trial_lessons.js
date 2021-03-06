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
      
      this.showSecondStep()
      
      event.preventDefault()
    }
    
    showSecondStep(){
      $("#secondStep").modal("show")
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

  application.register("trialagenda", class extends Stimulus.Controller {

    static get targets(){
      return ["timeSlot","day","trialCount"];
    }

    initialize(){
      this.openTimeSlot();
    }

    openTimeSlot(){
      if(this.data.get("openTrialId") && this.data.get("openTrialId") != ""){
        var el = this.trialCountTargets.filter((tc)=>{
          return JSON.parse(tc.dataset.trialIds).filter((tid)=>{
                   return tid == this.data.get("openTrialId");
                 }).length == 1;
        })[0];
        $(el).popover("show");
      }
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
