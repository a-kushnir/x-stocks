import ApplicationController from "controllers/application_controller";
import { cancel, cancelImmediate } from "helpers/event_helper";

export default class extends ApplicationController {
  cancel(event) {
    cancel(event);
  }

  cancelImmediate(event) {
    cancelImmediate(event);
  }
}
