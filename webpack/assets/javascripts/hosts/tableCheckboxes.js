/* eslint-disable jquery/no-param */
/* eslint-disable jquery/no-load */
/* eslint-disable jquery/no-hide */
/* eslint-disable jquery/no-show */
/* eslint-disable jquery/no-find */
/* eslint-disable jquery/no-text */
/* eslint-disable jquery/no-data */
/* eslint-disable jquery/no-val */
/* eslint-disable jquery/no-attr */
/* eslint-disable jquery/no-is */
/* eslint-disable jquery/no-html */
/* eslint-disable jquery/no-each */
/* eslint-disable jquery/no-submit */
/* eslint-disable jquery/no-in-array */

import $ from 'jquery';

import {
  sprintf,
  ngettext as n__,
  translate as __,
} from '../react_app/common/I18n';
import { getURIsearch } from '../react_app/common/urlHelpers';
import { foremanUrl } from '../foreman_tools';
import * as sessionStorage from './HostsSessionStorage';

// Array contains list of host ids
const cookieName = `_ForemanSelected${window.location.pathname.replace(
  /\//,
  ''
)}`;
let foremanSelectedHosts = readFromCookie();

// triggered by a host checkbox change
export function hostChecked({ id, checked }) {
  const multipleAlert = $('#multiple-alert');
  const cid = parseInt(id.replace('host_ids_', ''), 10);
  if (checked) addHostId(cid);
  else {
    rmHostId(cid);
    if (multipleAlert.length) {
      multipleAlert.hide('slow');
      multipleAlert.data('multiple', false);
    }
  }
  $.cookie(cookieName, JSON.stringify(foremanSelectedHosts), {
    secure: window.location.protocol === 'https:',
  });
  toggleActions();
  updateCounter();
  return false;
}

function addHostId(id) {
  if ($.inArray(id, foremanSelectedHosts) === -1) foremanSelectedHosts.push(id);
}

function rmHostId(id) {
  const pos = $.inArray(id, foremanSelectedHosts);
  if (pos >= 0) foremanSelectedHosts.splice(pos, 1);
}

function readFromCookie() {
  try {
    const r = $.cookie(cookieName);
    if (r) return $.parseJSON(r);
    return [];
  } catch (err) {
    removeForemanHostsCookie();
    return [];
  }
}

function toggleActions() {
  const dropDownContainer = $('#submit_multiple');
  const dropdown = dropDownContainer.find('a');
  const disabledMessage = __('Please select hosts to perform action on.');
  if (foremanSelectedHosts.length === 0) {
    dropdown.addClass('disabled');
    dropdown.attr('disabled', 'disabled');
    dropDownContainer.attr('title', disabledMessage);
  } else {
    dropdown.removeClass('disabled');
    dropdown.removeAttr('disabled');
    dropDownContainer.removeAttr('title');
  }
}

// setups checkbox values upon document load
$(document).on('ContentLoad', () => {
  if (window.location.pathname !== foremanUrl('/hosts')) return;

  const hostQuery = sessionStorage.getHostQuery();
  const uriSearch = getURIsearch();

  // clear selected hosts if new search occurs
  if (uriSearch !== '' && hostQuery !== uriSearch) {
    cleanHostsSelection();
    sessionStorage.setHostQuery(uriSearch);
    return;
  }
  sessionStorage.setHostQuery(uriSearch);

  for (let i = 0; i < foremanSelectedHosts.length; i++) {
    const cid = `host_ids_${foremanSelectedHosts[i]}`;
    const boxes = $(`#${cid}`);
    if (boxes && boxes[0]) boxes[0].checked = true;
  }
  toggleActions();
  updateCounter();
  $('#search-form').submit(() => {
    resetSelection();
  });

  // updates the form URL based on the action selection
  $('#confirmation-modal .secondary').click(() => {
    $('#confirmation-modal').modal('hide');
  });
});

function removeForemanHostsCookie() {
  $.removeCookie(cookieName);
}

export function resetSelection() {
  removeForemanHostsCookie();
  foremanSelectedHosts = [];
}

function cleanHostsSelection() {
  $('.host_select_boxes').each((index, box) => {
    box.checked = false;
    hostChecked(box);
  });
  resetSelection();
  toggleActions();
  updateCounter();
  return false;
}

export function multipleSelection() {
  const { total } = paginationMetaData();
  const alertText = sprintf(
    n__(
      'Single host is selected in total',
      'All <b> %d </b> hosts are selected.',
      total
    ),
    total
  );
  const undoText = __('Undo selection');
  const multpleAlert = $('#multiple-alert');
  multpleAlert
    .find('.text')
    .html(
      `${alertText} <a href="#" onclick="tfm.hosts.table.undoMultipleSelection();">${undoText}</a>`
    );
  multpleAlert.data('multiple', true);
  $('.select_count').html(total);
}

export function undoMultipleSelection() {
  const pagination = paginationMetaData();
  const alertText = sprintf(
    n__(
      'Single host on this page is selected.',
      'All %s hosts on this page are selected.',
      pagination.perPage
    ),
    pagination.perPage
  );
  const selectText = sprintf(
    n__('Select this host', 'Select all<b> %s </b> hosts', pagination.total),
    pagination.total
  );
  const multpleAlert = $('#multiple-alert');
  multpleAlert
    .find('.text')
    .html(
      `${alertText} <a href="#" onclick="tfm.hosts.table.multipleSelection();">${selectText}</a>`
    );
  multpleAlert.data('multiple', false);
  $('.select_count').html(pagination.perPage);
}

export function toggleCheck() {
  const pagination = paginationMetaData();
  const multpleAlert = $('#multiple-alert');
  const checked = $('#check_all').is(':checked');
  $('.host_select_boxes').each((index, box) => {
    box.checked = checked;
    hostChecked(box);
  });
  if (checked && pagination.perPage - pagination.total < 0) {
    multpleAlert.show('slow');
    multpleAlert.data('multiple', false);
  } else if (!checked) {
    multpleAlert.hide('slow');
    multpleAlert.data('multiple', false);
    cleanHostsSelection();
  }
  return false;
}

export function toggleMultipleOkButton({ value }) {
  const btn = $('#confirmation-modal .btn-primary');
  if (value !== 'disabled') btn.removeClass('disabled').attr('disabled', false);
  else btn.addClass('disabled').attr('disabled', true);
}

export function submitModalForm() {
  if (!$('#keep_selected').is(':checked')) removeForemanHostsCookie();
  if (isMultple()) {
    const query = $('<input>')
      .attr('type', 'hidden')
      .attr('name', 'search')
      .val(getURIsearch());
    $('#confirmation-modal form').append(query);
  }
  $('#confirmation-modal form').submit();
  $('#confirmation-modal').modal('hide');
}

function isMultple() {
  return $('#multiple-alert').data('multiple');
}

function getBulkParam() {
  return isMultple()
    ? { search: getURIsearch() }
    : { host_ids: foremanSelectedHosts };
}

export function buildModal(element, url) {
  const data = getBulkParam();
  const title = $(element).attr('data-dialog-title');
  $('#confirmation-modal .modal-header h4').text(title);
  $('#confirmation-modal .modal-body')
    .empty()
    .append("<div class='modal-spinner spinner spinner-lg'></div>");
  $('#confirmation-modal').modal();
  $('#confirmation-modal .modal-body').load(
    `${url} #content`,
    data,
    (response, status, xhr) => {
      $('#loading').hide();
      $('#submit_multiple').val('');
      if (isMultple()) $('#multiple-modal-alert').show();
      const b = $('#confirmation-modal .btn-primary');
      if ($(response).find('#content form select').length > 0)
        b.addClass('disabled').attr('disabled', true);
      else b.removeClass('disabled').attr('disabled', false);
    }
  );
  return false;
}

export function buildRedirect(url) {
  const data = getBulkParam();
  const redirectUrl = url.includes('?')
    ? `${url}&${$.param(data)}`
    : `${url}?${$.param(data)}`;

  window.location.replace(redirectUrl);
}

function paginationMetaData() {
  const total = Number(
    document.getElementsByClassName('pagination-pf-items-total')[0].textContent
  );
  const perPage = Number(
    document.getElementById('pagination-row-dropdown').textContent
  );
  return { total, perPage };
}

function updateCounter() {
  const item = $('#check_all');
  if (foremanSelectedHosts)
    $('.select_count').text(foremanSelectedHosts.length);
  let title = '';
  if (item.prop('checked') && foremanSelectedHosts)
    title = `${foremanSelectedHosts.length} - ${item.attr('uncheck-title')}`;
  else title = item.attr('check-title');

  item.attr('data-original-title', title);
  item.tooltip({
    trigger: 'hover',
  });
  return false;
}
