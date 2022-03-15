/* global Stimulus */
/* global $ */
(() => {
  stimulusApplication.register("easy-period", class extends Stimulus.Controller {

    static get targets(){
      return ["customPeriodContainer", "easyPeriodContainer"];
    }
    
    initialize(){
    }

    connect(){
    }

    showCustomPeriod(e){
      this.log("show custom start")
      let container = this.customPeriodContainerTarget
      container.querySelectorAll("select").forEach((input) => {
        input.disabled = false
      })
      this.easyPeriodContainerTarget.style.display = "none"
      container.style.display = "block"
      this.log("show custom end")
      e.preventDefault();
    }

    log(msg){
      console.log("[easy-period]" + msg)
    }

  });

})();
