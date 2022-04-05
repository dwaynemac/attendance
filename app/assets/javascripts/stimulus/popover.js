/* global Stimulus */
/* global $ */
(() => {
    const application = Stimulus.Application.start();

    application.register("popover", class extends Stimulus.Controller {

        static get targets() {
            return ["container"];
        }

        connect() {
            if(this.hasContainerTarget) {
                $(this.containerTarget).popover('enable');
            }
        }

        toggle(){
            $(this.containerTarget).popover('toggle');
        }

    });
})();