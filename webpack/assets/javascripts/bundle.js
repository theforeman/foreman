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
require('./bundle_novnc');

import compute from './foreman_compute_resource';
import componentRegistry from './react_app/components/componentRegistry';
import i18n from './react_app/common/I18n';

window.tfm = Object.assign(window.tfm || {}, {
  authSource: require('./foreman_auth_source'),
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
  nav: require('./foreman_navigation'),
  medium: require('./foreman_medium'),
  templateInputs: require('./foreman_template_inputs'),
  advancedFields: require('./foreman_advanced_fields'),
  breadcrumbs: require('./foreman_breadcrumbs'),
  configReportsModalDiff: require('./foreman_config_reports_modal_diff'),
  i18n,
  componentRegistry,
});
