// FOUC
document.querySelector('html').classList.replace('no-js', 'js');

// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import '@hotwired/turbo-rails';
import 'controllers';

// Legacy
import 'chart';
import 'chartjs-plugin-datalabels';
