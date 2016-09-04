require('expose?$!expose?jQuery!jquery');
require('./bundle_jquery_ui');
require('jquery-ujs');
require('expose?_!lodash');
require('expose?jstz!jstz');
require('jquery.cookie');
require('./bundle_flot');
require('./bundle_select2');
require('./bundle_datatables');
window.tfm = {
  tools: require('./foreman_tools')
};
