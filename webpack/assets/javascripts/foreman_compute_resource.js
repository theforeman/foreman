/* eslint-disable jquery/no-data */
/* eslint-disable jquery/no-find */
/* eslint-disable jquery/no-closest */
/* eslint-disable jquery/no-hide */
/* eslint-disable jquery/no-serialize */
/* eslint-disable jquery/no-html */
/* eslint-disable jquery/no-show */
/* eslint-disable jquery/no-prop */
/* eslint-disable jquery/no-class */
/* eslint-disable jquery/no-ajax */
/* eslint-disable jquery/no-val */
/* eslint-disable jquery/no-attr */
/* eslint-disable jquery/no-each */
/* eslint-disable jquery/no-filter */

import $ from 'jquery';
import { activateDatatables } from './foreman_tools';
import { notify } from './foreman_toast_notifications';
import { sprintf, translate as __ } from './react_app/common/I18n';
import * as ec2 from './compute_resource/ec2';
import * as libvirt from './compute_resource/libvirt';
import * as openstack from './compute_resource/openstack';
import * as ovirt from './compute_resource/ovirt';
import * as vmware from './compute_resource/vmware';

export default {
  ec2,
  libvirt,
  openstack,
  ovirt,
  vmware,
  capacityEdit,
  providerSelected,
  testConnection,
};

// Common functions used by one or more Compute Resource

// AJAX load vm listing

$(document).on('ContentLoad', () => {
  $('#vms, #images_list, #key_pairs_list')
    .filter('[data-url]')
    .each((i, el) => {
      const tab = $(el);
      const url = tab.attr('data-url');

      tab.load(`${url} table`, (response, status, xhr) => {
        if (status === 'error') {
          // eslint-disable-next-line function-paren-newline
          tab.html(
            // eslint-disable-next-line no-undef
            sprintf(
              __('There was an error listing VMs: %(status)s %(statusText)s'),
              {
                status: xhr.status,
                statusText: xhr.statusText,
              }
            )
          );
        } else {
          activateDatatables();
        }
      });
    });
});

// eslint-disable-next-line max-statements
export function providerSelected(item) {
  const computeConnection = $('#compute_connection');
  const provider = $(item).val();

  if (provider === '') {
    computeConnection.hide();
    $('[type=submit]').attr('disabled', true);
    return false;
  }
  $('[type=submit]').attr('disabled', false);
  const url = $(item).attr('data-url');
  const data = `provider=${provider}`;

  computeConnection.show();
  computeConnection.load(`${url} div#compute_connection`, data, () => {
    // eslint-disable-next-line no-undef
    password_caps_lock_hint();
    $('a[rel="popover"]').popover();
  });

  return false;
}

export function testConnection(item) {
  let crId = $('form').data('id');

  if (crId === undefined || crId === null) {
    crId = '';
  }

  const password = $('input#compute_resource_password').val();
  const passwordDisabled = $('#compute_resource_password').prop('disabled');

  $('.tab-error').removeClass('tab-error');
  $('#test_connection_indicator').show();
  $.ajax({
    type: 'put',
    url: $(item).attr('data-url'),
    data: `${$('form').serialize()}&cr_id=${crId}`,
    success(result) {
      const res = $(`<div>${result}</div>`);

      $('#compute_connection').html(res.find('#compute_connection'));
      $('#compute_connection').prepend(res.find('.alert'));
      if (
        $('.alert-danger', result).length === 0 &&
        $('#compute_connection .has-error', result).length === 0
      ) {
        notify({
          message: __('Test connection was successful'),
          type: 'success',
        });
      }
    },
    error({ statusText }) {
      notify({
        message: `${__(
          'An error occurred while testing the connection: '
        )}${statusText}`,
        type: 'danger',
      });
    },
    complete(result) {
      // we need to restore the password field as it is not sent back from the server.
      $('input#compute_resource_password').val(password);
      $('#compute_resource_password').prop('disabled', passwordDisabled);
      $('#test_connection_indicator').hide();
      // eslint-disable-next-line no-undef
      reloadOnAjaxComplete('#test_connection_indicator');
    },
  });
}

export function capacityEdit(element) {
  const buttons = $(element)
    .closest('.fields')
    .find('button[name=allocation_radio_btn].btn.active');

  if (buttons.length > 0 && buttons[0].id === 'btnAllocationFull') {
    const allocation = $(element)
      .closest('.fields')
      .find('[id$=allocation]')[0];

    allocation.value = element.value;
  }
  return false;
}
