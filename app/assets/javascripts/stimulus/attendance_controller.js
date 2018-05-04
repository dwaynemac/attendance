/* global Stimulus */
/* global $ */
(() => {
  const application = Stimulus.Application.start();
  
  application.register("attendance", class extends Stimulus.Controller {
    initialize(){
    }

    connect(){
      $("[data-toggle=popover]").popover()
    }
    
  });
    
})();
