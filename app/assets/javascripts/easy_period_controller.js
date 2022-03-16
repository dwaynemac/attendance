/* global Stimulus */
/* global $ */
(() => {
  stimulusApplication.register("easy-period", class extends Stimulus.Controller {

    static get targets(){
      return ["customPeriodContainer", "easyPeriodContainer", "selector", "field"];
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

    setEasyPeriod(e){
      if(e){ e.preventDefault() }
      let newPeriod = e.target.dataset.easyPeriod

      this.setActiveSelector(newPeriod)
      if (newPeriod === "custom"){
        this.fieldTarget.value = ""
        this.showCustomPeriod()
      } else {
        this.fieldTarget.value = newPeriod
        this.hideCustomPeriod()
      }

    }

    showCustomPeriod(e){
      if (e) {
        e.preventDefault();
      }
      let container = this.customPeriodContainerTarget
      container.querySelectorAll("select").forEach((input) => {
        input.disabled = false
      })
      container.style.display = "block"
    }

    hideCustomPeriod(e){
      if(e){ e.preventDefault() }
      let container = this.customPeriodContainerTarget
      container.querySelectorAll("select").forEach((input) => {
        input.disabled = true
      })
      container.style.display = "none"
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
