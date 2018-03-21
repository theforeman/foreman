/* eslint-disable global-require */
/* eslint-disable import/no-webpack-loader-syntax */
/* eslint-disable import/no-extraneous-dependencies */
/* eslint-disable import/no-unresolved */
/* eslint-disable import/extensions */
/* eslint-disable import/first */
import 'babel-polyfill';

require('expose-loader?$!expose-loader?jQuery!jquery');
require('jquery-ujs');
require('expose-loader?jstz!jstz');
require('expose-loader?ipaddr!ipaddr.js');
require('jquery.cookie');
require('expose-loader?JsDiff!diff');
require('./bundle_flot');
require('./bundle_multiselect');
require('./bundle_select2');
require('./bundle_datatables');
require('./bundle_lodash');

import compute from './foreman_compute_resource';

window.tfm = Object.assign(window.tfm || {}, {
  tools: require('./foreman_tools'),
  users: require('./foreman_users'),
  computeResource: compute,
  sshKeys: require('./foreman_ssh_keys'),
  trends: require('./foreman_trends'),
  hostgroups: require('./foreman_hostgroups'),
  hosts: require('./foreman_hosts'),
  httpProxies: require('./foreman_http_proxies'),
  toastNotifications: require('./foreman_toast_notifications'),
  numFields: require('./jquery.ui.custom_spinners'),
  reactMounter: require('./react_app/common/MountingService'),
  editor: require('./foreman_editor'),
  webmksConsole: require('./foreman_webmks_console'),
  nav: require('./foreman_navigation'),
  medium: require('./foreman_medium'),
});
