/* eslint-disable global-require */
/* eslint-disable import/no-webpack-loader-syntax */
/* eslint-disable import/no-extraneous-dependencies */
/* eslint-disable import/no-unresolved */
/* eslint-disable import/extensions */
/* eslint-disable import/first */

// Set the public path for dynamic imports
if (process.env.NODE_ENV !== 'production') {
  /* eslint-disable-next-line */
  __webpack_public_path__ =`${window.location.protocol}//${window.location.hostname}:3808/webpack/`;
}

import 'babel-polyfill';

require('expose-loader?$!expose-loader?jQuery!jquery');
require('jquery-ujs');
require('expose-loader?jstz!jstz');
require('expose-loader?ipaddr!ipaddr.js');
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
import * as foremanDocument from './react_app/common/document';
import hosts from './foreman_hosts';
import * as foremanStore from './foreman_store';

window.tfm = Object.assign(window.tfm || {}, {
  authSource: require('./foreman_auth_source'),
  tools: require('./foreman_tools'),
  users: require('./foreman_users'),
  computeResource: compute,
  sshKeys: require('./foreman_ssh_keys'),
  trends: require('./foreman_trends'),
  hostgroups: require('./foreman_hostgroups'),
  hosts,
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
  classEditor: require('./foreman_class_edit'),
  dashboard: require('./foreman_dashboard'),
  spice: require('./spice'),
  i18n,
  document: foremanDocument,
  componentRegistry,
  store: foremanStore,
});
