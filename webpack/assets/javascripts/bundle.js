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

window.tfm = Object.assign(
  window.tfm || {},
  {
    tools: require('./foreman_tools'),
    users: require('./foreman_users'),
    trends: require('./foreman_trends'),
    hostgroups: require('./foreman_hostgroups'),
    toastNotifications: require('./foreman_toast_notifications'),
    numFields: require('./jquery.ui.custom_spinners'),
    reactMounter: require('./react_app/common/MountingService')
  }
);
