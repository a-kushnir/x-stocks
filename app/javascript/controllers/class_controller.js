import ApplicationController from 'controllers/application_controller';

export default class extends ApplicationController {
  static targets = ['element'];

  toggle() {
    this.elementTargets.forEach((element) => {
      element.classList.toggle(element.dataset.classValue);
    });
  }

  set() {
    this.elementTargets.forEach((element) => {
      element.classList.add(element.dataset.classValue);
    });
  }

  unset() {
    this.elementTargets.forEach((element) => {
      element.classList.remove(element.dataset.classValue);
    });
  }
}
