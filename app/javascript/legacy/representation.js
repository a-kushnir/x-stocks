window.init_representation = function(table, charts, table_radio, charts_radio) {
  if (location.hash === "#charts") {
    switch_representation_to_charts(table, charts);
    $(charts_radio).parents('label').button('toggle');
  } else {
    switch_representation_to_table(table, charts);
    $(table_radio).parents('label').button('toggle');
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

window.switch_representation_to_excel = function(table, charts, table_radio, charts_radio) {
  table = $(table);
  charts = $(charts);
  if ($(table).length === 0 || $(charts).length === 0) return;

  setTimeout(function() {
    if (location.hash === "#charts") {
      $(charts_radio).parents('label').button('toggle');
    } else {
      $(table_radio).parents('label').button('toggle');
    }
  },100);

  location.href = location.protocol + '//'+ location.host + location.pathname + '.xlsx'
}

window.switch_representation_to_charts = function(table, charts) {
  table = $(table);
  charts = $(charts);
  if ($(table).length === 0 || $(charts).length === 0) return;
  table.hide();
  charts.show();
  location.hash = "#charts";
}
