import ApplicationController from "controllers/application_controller";
import { runEventSource, submitEventSource } from "helpers/event_source_helper";
import { setProgressValue, setProgressColor } from "helpers/progress_bar_helper"
import { escapeHTML } from "helpers/string_helper"

export default class extends ApplicationController {
  static values = {
    symbol: String,
    outputContainer: String,
    outputProgress: String,
    outputMessage: String
  }
  static targets = [ 'output' ]

  run(event) {
    const form = event.currentTarget.form;

    const outputContainer = document.getElementById(this.outputContainerValue);
    const outputProgress = document.getElementById(this.outputProgressValue);
    const outputMessage = document.getElementById(this.outputMessageValue);

    outputContainer.classList.remove('hidden');

    const colors = ['bg-blue-600', 'bg-red-600'];
    setProgressValue(outputProgress, 0);
    setProgressColor(outputProgress, 'bg-blue-600', colors);
    outputMessage.textContent = 'Connecting to server...';

    let success = false;
    const esComponent = submitEventSource(form, {
      message: function(data) {
        setProgressValue(outputProgress, data.percent);
        outputMessage.textContent = data.message;
        success = true;
      },
      error: function(data) {
        console.error(data);
        outputMessage.textContent = `Error ${escapeHTML(data.message)}`;
        setProgressColor(outputProgress, 'bg-red-600', colors);
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

  }

  updateStock() {
    this.element.disabled = true;
    const output = this.outputTarget;
    output.textContent = 'Updating... 0%';

    runEventSource(`/services/stock_one/run`, {
      data: { symbol: this.symbolValue },
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
