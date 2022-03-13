import ApplicationController from "controllers/application_controller";
import { cancel } from "helpers/event_helper";

export default class extends ApplicationController {
  static targets = [ "element" ]

  toggle(event) {
    cancel(event);

    this.elementTargets.forEach((element) => {
      element.classList.toggle(element.dataset.classValue);
    });
  }
}
