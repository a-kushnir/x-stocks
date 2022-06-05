import ApplicationController from "controllers/application_controller";
import { runEventSource, submitEventSource } from "helpers/event_source_helper";
import { setProgressValue, setProgressColor } from "helpers/progress_bar_helper"
import { escapeHTML } from "helpers/string_helper"

export default class extends ApplicationController {
  static values = {
    code: String,
    params: String,
    outputContainer: String,
    outputProgress: String,
    outputMessage: String
  }
  static targets = [ 'output', 'form' ]

  start(event) {
    const form = event.currentTarget.form || this.formTarget;

    const outputContainer = document.getElementById(this.outputContainerValue);
    const outputProgress = document.getElementById(this.outputProgressValue);
    const outputMessage = document.getElementById(this.outputMessageValue);

    if (outputContainer.esComponent) {
      outputContainer.esComponent.close();
    }
    outputContainer.classList.remove('hidden');

    setProgressValue(outputProgress, 0);
    setProgressColor(outputProgress, 'bg-blue-600', ['bg-red-600']);
    outputMessage.textContent = 'Connecting to server...';

    let success = false;
    outputContainer.esComponent = submitEventSource(form, {
      message: function(data) {
        setProgressValue(outputProgress, data.percent);
        outputMessage.textContent = data.message;
        success = true;
      },
      redirect: function(location) {
        window.location.replace(location);
      },
      error: function(data) {
        console.error(data);
        outputMessage.textContent = `Error ${escapeHTML(data.message)}`;
        setProgressColor(outputProgress, 'bg-red-600', ['bg-blue-600']);
      },
      open: function() {
        outputMessage.textContent = 'Retrieving information...'
      },
      closed: function() {
        if (success) {
          outputContainer.classList.add('hidden');
        } else {
          // ??
        }
      }
    })
  }

  stop() {
    if (!this.element.esComponent) { return; }

    if (confirm('Are you sure you want to stop the service?')) {
      this.stopNoConfirm();
    }
  }

  stopNoConfirm() {
    if (!this.element.esComponent) { return; }

    this.element.esComponent.close();
    this.element.esComponent = null;

    const outputProgress = document.getElementById(this.outputProgressValue);
    const outputMessage = document.getElementById(this.outputMessageValue);

    setProgressColor(outputProgress, 'bg-red-600', ['bg-blue-600']);
    outputMessage.textContent = 'Cancelled';
  }

  run() {
    this.element.disabled = true;
    const output = this.outputTarget;
    output.textContent = 'Updating... 0%';

    runEventSource(`/services/${this.codeValue}/run`, {
      data: this.hasParamsValue ? JSON.parse(this.paramsValue) : {},
      message: function(data) {
        output.textContent = `Updating... ${data.percent}%`;
      },
      closed: function() {
        output.textContent = 'Reloading...';
        location.reload();
      },
      error: function (data) {
        console.error(data);
        output.textContent = `Error ${escapeHTML(data.message)}`;
      }
    })
  }

  updateStocks() {
    const output = this.outputTarget;
    output.textContent = 'Updating...';

    runEventSource('/services/run', {
      closed: function() {
        output.textContent = 'Updated';
      },
      error: function (data) {
        console.error(data);
        output.textContent = `Error ${escapeHTML(data.message)}`;
      }
    })
  }
}
