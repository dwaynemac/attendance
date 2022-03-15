/* global Stimulus */
/* global $ */
(() => {
  stimulusApplication.register("easy-period", class extends Stimulus.Controller {

    static get targets(){
      return ["customPeriodContainer", "easyPeriodContainer", "selector"];
    }
    
    initialize(){
      if (!this.isCustomPeriodSet()) {
        this.showCustomPeriod()
      }
    }

    connect(){
      if (!this.isCustomPeriodSet()) {
        this.showCustomPeriod()
      }
    }

    showCustomPeriod(e){
      if (e) {
        e.preventDefault();
      }
      this.log("show custom start")
      let container = this.customPeriodContainerTarget
      container.querySelectorAll("select").forEach((input) => {
        input.disabled = false
      })
      this.setActiveSelector("custom")
      //this.easyPeriodContainerTarget.style.display = "none"
      container.style.display = "block"
      this.log("show custom end")
    }

    isCustomPeriodSet(){
      return this.data.get("paramsPeriod") === "current_month" || this.data.get("paramsPeriod") === "last_month"
    }

    setActiveSelector(value){
      this.selectorTargets.forEach((s) => {
        if (s.dataset.selectorValue === value) {
          s.classList.add("active")
        } else {
          s.classList.remove("active")
        }
      })
    }

    log(msg){
      console.log("[easy-period]" + msg)
    }

  });

})();
