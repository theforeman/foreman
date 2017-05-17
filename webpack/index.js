require('expose?$!expose?jQuery!jquery');
require('jquery-ujs');
require('expose?_!lodash');
require('expose?jstz!jstz');
require('expose?ipaddr!ipaddr.js');
require('jquery.cookie');
require('expose?JsDiff!diff');
require('./modules/bundle_flot');
require('./modules/bundle_multiselect');
require('./modules/bundle_select2');
require('./modules/bundle_datatables');

window.tfm = Object.assign(
  window.tfm || {},
  {
    tools: require('./modules/foreman_tools'),
    users: require('./modules/foreman_users'),
    sshKeys: require('./modules/foreman_ssh_keys'),
    trends: require('./modules/foreman_trends'),
    hostgroups: require('./modules/foreman_hostgroups'),
    toastNotifications: require('./modules/foreman_toast_notifications'),
    numFields: require('./modules/jquery.ui.custom_spinners'),
    reactMounter: require('./react_app/common/MountingService'),
    editor: require('./modules/foreman_editor')
  }
);
