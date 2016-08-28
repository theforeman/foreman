require('expose?$!expose?jQuery!jquery');
require('jquery-ujs');
require('expose?_!lodash');
require('expose?jstz!jstz');
require('expose?ipaddr!ipaddr.js');
require('jquery.cookie');
require('expose?JsDiff!diff');
require('./bundle_flot');
require('./bundle_select2');
require('./bundle_datatables');
window.tfm = {
  tools: require('./foreman_tools'),
  initByteSpinner: require('./jquery.ui.custom_spinners').initByteSpinner
};
