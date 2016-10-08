require('expose?$!expose?jQuery!jquery');
require('jquery-ujs');
require('expose?_!lodash');
require('expose?jstz!jstz');
require('expose?ipaddr!ipaddr.js');
require('jquery.cookie');
require('expose?JsDiff!diff');
require('./bundle_flot');
require('./bundle_multiselect');
require('./bundle_select2');
require('./bundle_datatables');

window.tfm = {
  turboLinks: require('turbolinks'),
  tools: require('./foreman_tools'),
  numFields: require('./jquery.ui.custom_spinners')
};

tfm.turboLinks.start();
