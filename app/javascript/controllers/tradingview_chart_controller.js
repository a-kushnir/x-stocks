import ApplicationController from "controllers/application_controller";
import { generateId } from "helpers/string_helper";

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
        "timezone": "Etc/UTC",
        "theme": "light",
        "style": "2",
        "locale": "en",
        "toolbar_bg": "#f1f3f6",
        "enable_publishing": false,
        "hide_top_toolbar": true,
        "withdateranges": true,
        "range": "1m",
        "allow_symbol_change": true,
        "save_image": false,
        "container_id": this.element.id
      });
    });
  }
}
