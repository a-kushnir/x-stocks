require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

var jQuery = require("jquery");
global.$ = global.jQuery = jQuery;
window.$ = window.jQuery = jQuery;

require("bootstrap");
require("packs/data_refresh");

document.addEventListener("turbolinks:load", () => {
    $('[data-toggle="tooltip"]').tooltip()
})

document.addEventListener("turbolinks:load", () => {
    if (typeof on_page_load === 'function')
        on_page_load();
})

require("chart.js")
