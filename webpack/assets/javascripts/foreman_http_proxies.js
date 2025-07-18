/* eslint-disable jquery/no-serialize */
/* eslint-disable jquery/no-show */
/* eslint-disable jquery/no-class */
/* eslint-disable jquery/no-ajax */
/* eslint-disable jquery/no-hide */

import $ from 'jquery';
import { notify, clear } from './foreman_toast_notifications';

export function testConnection(item, url) {
  // Get HTTP proxy ID for existing records, but only if password field is disabled
  // If password field is enabled, user wants to test with new password from form
  let httpProxyId = '';
  const passwordField = $('#http_proxy_password');

  if (passwordField.length > 0 && passwordField.prop('disabled')) {
    // Password field is disabled, so use existing password from database
    const formElement = $('form')[0];
    httpProxyId = formElement.dataset.id || '';
  }
  // If password field is enabled, leave httpProxyId empty so controller uses form password

  const serializedArray = $('form').serializeArray();
  const formData = new URLSearchParams(
    serializedArray.map(({ name, value }) => [name, value])
  );
  formData.append('http_proxy_id', httpProxyId);
  const data = formData.toString();

  $('#test_connection_indicator').show();
  $(item).addClass('disabled');
  clear();
  $.ajax({
    url,
    type: 'put',
    data,
    success(result, textstatus, xhr) {
      notify({ message: result.message, type: 'success' });
    },
    error(xhr) {
      const error = JSON.parse(xhr.responseText).message;

      notify({ message: error, type: 'danger' });
    },
    complete(result) {
      $('#test_connection_indicator').hide();
      $(item).removeClass('disabled');
    },
  });
}
