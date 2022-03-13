import ApplicationController from "controllers/application_controller";

export default class extends ApplicationController {
  static targets = [ "element" ]

  toggle(event) {
    this.elementTargets.forEach((element) => {
      element.classList.toggle(element.dataset.classValue);
    });
  }
}
