import ApplicationController from "controllers/application_controller";
import { generateId } from "helpers/string_helper";
import { isDarkTheme } from "helpers/theme_helper";

export default class extends ApplicationController {
  static values = { symbol: String }

  connect() {
    if (!this.element.id) {
      this.element.id = generateId();
    }

    import("https://s3.tradingview.com/tv.js").then(() => {
      new TradingView.widget({
        "autosize": true,
        "symbol": this.symbolValue,
        "interval": "D",
        "timezone": "Etc/UTC",
        "theme": isDarkTheme() ? "dark" : "light",
        "style": "2",
        "locale": "en",
        "hide_top_toolbar": true,
        "withdateranges": true,
        "range": "12m",
        "container_id": this.element.id,
        "studies": [{
          "id": "MAExp@tv-basicstudies",
          "inputs": {
            "length": 125
          }
        }],
        "studies_overrides": {
          "moving average exponential.ma.color.0": "#FF9800"
        }
      });
    });
  }
}
