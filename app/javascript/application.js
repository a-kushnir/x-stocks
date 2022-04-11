// FOUC
document.querySelector('html').classList.replace('no-js', 'js');

// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Legacy
import "bootstrap"
import "chart"
import "chartjs-plugin-datalabels"
import "legacy/data_table"
import "legacy/bootstrap"
import "legacy/eventsource"
import "legacy/service-runner"
import "legacy/stock_refresh"
import "legacy/data_refresh"
import "legacy/datatables"
import "legacy/local-store"
import "legacy/money_format"
import "legacy/checkbox-menu"
import "https://s3.tradingview.com/tv.js"
