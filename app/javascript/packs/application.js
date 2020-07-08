require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

var jQuery = require("jquery");
global.$ = global.jQuery = jQuery;
window.$ = window.jQuery = jQuery;

require("bootstrap");

document.addEventListener("turbolinks:load", () => {
    $('[data-toggle="tooltip"]').tooltip()
})
