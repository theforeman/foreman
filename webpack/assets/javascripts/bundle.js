/* eslint-disable global-require */
/* eslint-disable import/no-webpack-loader-syntax */
/* eslint-disable import/no-extraneous-dependencies */
/* eslint-disable import/no-unresolved */
/* eslint-disable import/extensions */
/* eslint-disable import/first */
import 'babel-polyfill';

import 'expose-loader?$!expose-loader?jQuery!jquery';
import 'jquery-ujs';
import 'expose-loader?jstz!jstz';
import 'expose-loader?ipaddr!ipaddr.js';
import 'jquery.cookie';
import 'expose-loader?JsDiff!diff';
import './bundle_flot';
import './bundle_multiselect';
import './bundle_select2';
import './bundle_lodash';
import './bundle_datatables';

import '../stylesheets/application.scss';

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
  nav: require('./foreman_navigation'),
  medium: require('./foreman_medium'),
});
