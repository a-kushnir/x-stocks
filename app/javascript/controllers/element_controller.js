import ApplicationController from "controllers/application_controller";

export default class extends ApplicationController {
  requestSubmit() {
    this.element.form.requestSubmit();
  }

  scrollTo() {
    let target = this.element.dataset.elementScrollTarget;
    target = document.getElementById(target);
    target.scrollIntoView({ behavior: 'smooth' }); // { behavior: 'auto' }
  }
}
