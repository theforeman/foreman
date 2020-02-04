import 'core-js/shim';
import 'regenerator-runtime/runtime';

import compute from './foreman_compute_resource';
import componentRegistry from './react_app/components/componentRegistry';
import i18n from './react_app/common/I18n';
import * as document from './react_app/common/document';
import hosts from './foreman_hosts';
import * as store from './foreman_store';
import * as authSource from './foreman_auth_source';
import * as tools from './foreman_tools';
import * as users from './foreman_users';
import * as sshKeys from './foreman_ssh_keys';
import * as trends from './foreman_trends';
import * as hostgroups from './foreman_hostgroups';
import * as httpProxies from './foreman_http_proxies';
import * as toastNotifications from './foreman_toast_notifications';
import * as numFields from './jquery.ui.custom_spinners';
import * as reactMounter from './react_app/common/MountingService';
import * as editor from './foreman_editor';
import * as nav from './foreman_navigation';
import * as medium from './foreman_medium';
import * as templateInputs from './foreman_template_inputs';
import * as advancedFields from './foreman_advanced_fields';
import * as configReportsModalDiff from './foreman_config_reports_modal_diff';
import * as classEditor from './foreman_class_edit';
import * as dashboard from './dashboard';
import * as spice from './spice';
import * as autocomplete from './foreman_autocomplete';
import * as typeAheadSelect from './foreman_type_ahead_select';
import './bundle_novnc';

// Set the public path for dynamic imports
if (process.env.NODE_ENV !== 'production') {
  /* eslint-disable-next-line */
  __webpack_public_path__ = `${window.location.protocol}//${window.location.hostname}:3808/webpack/`;
}

window.tfm = Object.assign(window.tfm || {}, {
  authSource,
  tools,
  users,
  computeResource: compute,
  sshKeys,
  trends,
  hostgroups,
  hosts,
  httpProxies,
  toastNotifications,
  numFields,
  reactMounter,
  editor,
  nav,
  medium,
  templateInputs,
  advancedFields,
  configReportsModalDiff,
  classEditor,
  dashboard,
  i18n,
  spice,
  document,
  componentRegistry,
  store,
  autocomplete,
  typeAheadSelect,
});
