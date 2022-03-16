import ApplicationController from "controllers/application_controller";

export default class extends ApplicationController {
  static values = { datetime: String, handle: Number }
  static targets = [ "days", "hours", "minutes", "seconds" ]

  connect() {
    this.disconnect();
    this.update();
    this.handleValue = setInterval(() => { this.update() }, 1000);
  }

  disconnect() {
    if (this.hasHandleValue) {
      clearInterval(this.handleValue);
      this.handleValue = undefined;
    }
  }

  update() {
    let now = new Date();
    let target = new Date(this.datetimeValue);
    let diff = Math.floor((target.valueOf() - now.valueOf()) / 1000);

    if (diff <= 0) {
      diff = 0;
      this.disconnect();
    }

    const seconds = diff % 60;
    const minutes = Math.floor(diff / 60) % 60;
    const hours = Math.floor(diff / (60 * 60)) % 24;
    const days = Math.floor(diff / (60 * 60 * 24));

    if (this.hasDaysTarget) this.daysTarget.innerHTML = days;
    if (this.hasHoursTarget) this.hoursTarget.innerHTML = hours.toString().padStart(2, '0');
    if (this.hasMinutesTarget) this.minutesTarget.innerHTML = minutes.toString().padStart(2, '0');
    if (this.hasSecondsTarget) this.secondsTarget.innerHTML = seconds.toString().padStart(2, '0');
  }
}
