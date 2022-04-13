// FOUC
document.querySelector('html').classList.replace('no-js', 'js');

// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Legacy
import "bootstrap"
import "chart"
import "chartjs-plugin-datalabels"
import "legacy/eventsource"
import "legacy/service-runner"
import "legacy/data_refresh"
import "https://s3.tradingview.com/tv.js"
