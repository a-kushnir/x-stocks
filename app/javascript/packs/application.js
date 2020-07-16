require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

const jQuery = require("jquery");
global.$ = global.jQuery = jQuery;
window.$ = window.jQuery = jQuery;

require("bootstrap");
document.addEventListener("turbolinks:load", () => {
    $('[data-toggle="tooltip"]').tooltip()
})

require("chart.js")
require("chartjs-plugin-datalabels")

require("packs/data_refresh");
require("packs/data_table");
require("packs/twitter");
require("packs/charts");
