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


window.init_representation = function(table, charts, table_radio, charts_radio) {
    if (location.hash === "#charts") {
        switch_representation_to_charts(table, charts);
        $(charts_radio).prop('checked', true);
    } else {
        switch_representation_to_table(table, charts);
        $(table_radio).prop('checked', true);
    }
}

window.switch_representation_to_table = function(table, charts) {
    table = $(table);
    charts = $(charts);
    if ($(table).length === 0 || $(charts).length === 0) return;
    table.show();
    charts.hide();
    location.hash = "#table";
}

window.switch_representation_to_charts = function(table, charts) {
    table = $(table);
    charts = $(charts);
    if ($(table).length === 0 || $(charts).length === 0) return;
    table.hide();
    charts.show();
    location.hash = "#charts";
}
