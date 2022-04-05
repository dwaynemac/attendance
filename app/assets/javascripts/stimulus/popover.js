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
                // this is a workaround for links in popovers
                // if the link is clicked but the button not released immediately
                // then the popover dissapears and the action is not taken place
                // the same happens when you touch the link with the touchpad
                // instead of clicking with the buttons of the touchpad
                $(this.containerTarget).on('focus', function() {
                    $(this).popover('show');
                }).on('focusout', function() {
                    var _this;
                    _this = this;
                    if (!$('.popover:hover').length) {
                        $(this).popover('hide');
                    } else {
                        $('.popover').on('mouseleave', function() {
                            $(_this).popover('hide');
                            $(this).off('mouseleave');
                        });
                        $(".popover-edit").on('click', function() {
                            $(".popover").off('mouseleave');
                            $(_this).popover('hide');
                        });
                    }
                });
            }
        }

        toggle(){
            $(this.containerTarget).popover('toggle');
        }

    });
})();