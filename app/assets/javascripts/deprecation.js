// this file contains deprecated functions

function toggle_multiple_ok_button(element) {
  tfm.tools.deprecate(
    'toggle_multiple_ok_button',
    'tfm.hosts.table.toggleMultipleOkButton',
    '1.24'
  );
  return tfm.hosts.table.toggleMultipleOkButton(element);
}

function build_modal(element, args) {
  tfm.tools.deprecate('build_modal', 'tfm.hosts.table.buildModal', '1.24');
  return tfm.hosts.table.buildModal(element, args);
}

function submit_modal_form(args) {
  tfm.tools.deprecate(
    'submit_modal_form',
    'tfm.hosts.table.submitModalForm',
    '1.24'
  );
  return tfm.hosts.table.submitModalForm(args);
}

function build_redirect(args) {
  tfm.tools.deprecate(
    'build_redirect',
    'tfm.hosts.table.buildRedirect',
    '1.24'
  );
  return tfm.hosts.table.buildRedirect(args);
}

function toggleCheck(args) {
  tfm.tools.deprecate('toggleCheck', 'tfm.hosts.table.toggleCheck', '1.24');
  return tfm.hosts.table.toggleCheck(args);
}

function hostChecked(args) {
  tfm.tools.deprecate('hostChecked', 'tfm.hosts.table.hostChecked', '1.24');
  return tfm.hosts.table.hostChecked(args);
}

function foreman_url(url) {
  tfm.tools.deprecate('foreman_url', 'tfm.tools.foremanUrl', '1.24');
  return tfm.tools.foremanUrl(url);
}
