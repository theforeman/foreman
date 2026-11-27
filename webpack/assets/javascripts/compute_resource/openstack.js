/* eslint-disable jquery/no-val */
/* eslint-disable jquery/no-attr */
/* eslint-disable jquery/no-find */
/* eslint-disable jquery/no-prop */
/* eslint-disable jquery/no-toggle */
/* eslint-disable jquery/no-ajax */
/* eslint-disable jquery/no-html */
/* eslint-disable jquery/no-class */

import $ from 'jquery';
import { showSpinner, hideSpinner } from '../foreman_tools';
import { sprintf, translate as __ } from '../react_app/common/I18n';

export function authenticationTypeSelected(item) {
  const selector = $(item);
  const applicationCredentials = selector.val() === 'application_credentials';
  const passwordCredentials = $('#openstack_password_credentials');
  const applicationCredentialFields = $('#openstack_application_credentials');

  passwordCredentials.toggle(!applicationCredentials);
  passwordCredentials.find(':input').prop('disabled', applicationCredentials);
  applicationCredentialFields.toggle(applicationCredentials);
  applicationCredentialFields
    .find(':input')
    .prop('disabled', !applicationCredentials);

  const label = applicationCredentials
    ? selector.attr('data-application-credential-label')
    : selector.attr('data-password-label');
  const credentialSecretLabel = document.querySelector(
    '#openstack_credential_secret .control-label'
  );
  if (credentialSecretLabel) credentialSecretLabel.textContent = `${label} *`;

  const password = $('#compute_resource_password');
  const authenticationChanged =
    selector.val() !== selector.attr('data-original-value');
  if (authenticationChanged) {
    password.val('').prop('disabled', false);
  } else if (selector.attr('data-persisted') === 'true') {
    password.val('').prop('disabled', true);
  }
}

export function schedulerHintFilterSelected(item) {
  const filter = $(item).val();

  if (filter === '') {
    $('#scheduler_hint_wrapper').empty();
  } else {
    const url = $(item).attr('data-url');
    // eslint-disable-next-line no-undef
    const data = serializeForm().replace('method=patch', 'method=post');

    showSpinner();
    $.ajax({
      type: 'post',
      url,
      data,
      complete() {
        hideSpinner();
      },
      error(jqXHR, status, error) {
        $('#scheduler_hint_wrapper').html(
          sprintf(
            __('Error loading scheduler hint filters information: %s'),
            error
          )
        );
        $('#compute_resource_tab a').addClass('tab-error');
      },
      success(result) {
        $('#scheduler_hint_wrapper').html(result);
      },
    });
  }
}
