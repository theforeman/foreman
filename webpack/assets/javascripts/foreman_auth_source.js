/* eslint-disable jquery/no-val */
/* eslint-disable jquery/no-toggle */
/* eslint-disable jquery/no-closest */
/* eslint-disable jquery/no-ready */
/* eslint-disable jquery/no-each */
/* eslint-disable jquery/no-is */
/* eslint-disable jquery/no-show */
/* eslint-disable jquery/no-class */
/* eslint-disable jquery/no-serialize */
/* eslint-disable jquery/no-ajax */
/* eslint-disable jquery/no-hide */

import $ from 'jquery';
import { notify } from './foreman_toast_notifications';

export function testConnection(item, url) {
  $('#test_connection_indicator').show();
  $(item).addClass('disabled');
  const data = $('form').serialize();
  $.ajax({
    url,
    type: 'put',
    data,
    success({ message }, textstatus, xhr) {
      notify({ message, type: 'success' });
    },
    error({ responseText }) {
      const error = $.parseJSON(responseText).message;
      notify({ message: error, type: 'danger' });
    },
    complete(result) {
      $('#test_connection_indicator').hide();
      $(item).removeClass('disabled');
    },
  });
}

export function changeLdapPort(item) {
  const port = $('#auth_source_ldap_port');

  if (port.length > 0) {
    const value = parseInt(port.val(), 10);
    const defaultPorts = port.data('default-ports');
    if (
      !Number.isNaN(value) &&
      defaultPorts != null &&
      defaultPorts.ldap != null &&
      defaultPorts.ldaps != null
    ) {
      if ($(item).is(':checked')) {
        if (value === defaultPorts.ldap) {
          port.val(defaultPorts.ldaps);
        }
      } else if (value === defaultPorts.ldaps) {
        port.val(defaultPorts.ldap);
      }
    }
  }
}

function updateLdapAccountHelp(selectedType) {
  $.each(['account', 'base_dn', 'groups_base'], (index, value) => {
    const element = $(`#auth_source_ldap_${value}`);
    const help = element.data('help')[selectedType];

    if (help !== undefined) {
      element
        .parents('.form-group')
        .find('label a[rel=popover]')
        .attr('data-content', help);
      element
        .parents('.form-group')
        .find('label a[rel=popover]')
        .show();
    } else {
      element
        .parents('.form-group')
        .find('label a[rel=popover]')
        .hide();
    }
  });
}

export function changeLdapServerType() {
  const type = $('#auth_source_ldap_server_type').val();
  $('#auth_source_ldap_use_netgroups')
    .closest('.form-group')
    .toggle(type !== 'active_directory');
  updateLdapAccountHelp(type);
}

$(document).ready(() => {
  if (window.location.pathname.match('auth_source_ldaps/i')) {
    changeLdapServerType();
  }
});
