import ApplicationController from "controllers/application_controller";

export default class extends ApplicationController {
  requestSubmit() {
    this.element.form.requestSubmit();
  }
}
