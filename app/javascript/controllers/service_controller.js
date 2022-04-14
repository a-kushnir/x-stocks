import ApplicationController from "controllers/application_controller";
import { runEventSource } from "helpers/event_source_helper";

export default class extends ApplicationController {
  static values = { symbol: String }
  static targets = [ 'output' ]

  updateStock() {
    this.element.disabled = true;
    const output = this.outputTarget;
    output.textContent = 'Updating... 0%';

    runEventSource(`/services/stock_one/run`, {
      data: [{ name: 'symbol', value: this.symbolValue }],
      message: function(data) {
        output.textContent = `Updating... ${data.percent}%`;
      },
      closed: function() {
        output.textContent = 'Reloading...';
        location.reload();
      },
      error: function (data) {
        output.textContent = 'Error';
        console.error(data);
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
        output.textContent = 'Error';
        console.error(data);
      }
    })
  }
}
