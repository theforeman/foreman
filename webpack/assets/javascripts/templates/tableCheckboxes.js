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

// Array contains list of template ids
const cookieName = `_ForemanSelected${window.location.pathname.replace(
  /\//,
  ''
)}`;
let foremanSelectedTemplates = readFromCookie();

// triggered by a template checkbox change
export function templateChecked({ id, checked }) {
  const multipleAlert = $('#multiple-alert');
  const cid = parseInt(id.replace('template_ids_', ''), 10);
  if (checked) addTemplateId(cid);
  else {
    rmTemplateId(cid);
    if (multipleAlert.length) {
      multipleAlert.hide('slow');
      multipleAlert.data('multiple', false);
    }
  }
  $.cookie(cookieName, JSON.stringify(foremanSelectedTemplates), {
    secure: window.location.protocol === 'https:',
  });
  toggleActions();
  updateCounter();
  return false;
}

function addTemplateId(id) {
  if ($.inArray(id, foremanSelectedTemplates) === -1) foremanSelectedTemplates.push(id);
}

function rmTemplateId(id) {
  const pos = $.inArray(id, foremanSelectedTemplates);
  if (pos >= 0) foremanSelectedTemplates.splice(pos, 1);
}

function readFromCookie() {
  try {
    const r = $.cookie(cookieName);
    if (r) return $.parseJSON(r);
    return [];
  } catch (err) {
    removeForemanTemplatesCookie();
    return [];
  }
}

function toggleActions() {
  const dropDownContainer = $('#submit_multiple');
  const dropdown = dropDownContainer.find('a');
  const disabledMessage = __('Please select templates to perform action on.');
  if (foremanSelectedTemplates.length === 0) {
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
  //                                           TODO: generic
  if (window.location.pathname !== foremanUrl('/templates/report_templates')) return;

  const templateQuery = sessionStorage.getItem('templateQuery');
  const uriSearch = getURIsearch();

  // clear selected templates if new search occurs
  if (uriSearch !== '' && templateQuery !== uriSearch) {
    cleanTemplatesSelection();
    sessionStorage.setItem('templateQuery', uriSearch);
    return;
  }
  sessionStorage.setItem('templateQuery', uriSearch);

  for (let i = 0; i < foremanSelectedTemplates.length; i++) {
    const cid = `template_ids_${foremanSelectedTemplates[i]}`;
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

function removeForemanTemplatesCookie() {
  $.removeCookie(cookieName);
}

export function resetSelection() {
  removeForemanTemplatesCookie();
  foremanSelectedTemplates = [];
}

function cleanTemplatesSelection() {
  $('.template_select_boxes').each((index, box) => {
    box.checked = false;
    templateChecked(box);
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
      'Single template is selected in total',
      'All <b> %d </b> templates are selected.',
      total
    ),
    total
  );
  const undoText = __('Undo selection');
  const multpleAlert = $('#multiple-alert');
  multpleAlert
    .find('.text')
    .html(
      `${alertText} <a href="#" onclick="tfm.templates.table.undoMultipleSelection();">${undoText}</a>`
    );
  multpleAlert.data('multiple', true);
  $('.select_count').html(total);
}

export function undoMultipleSelection() {
  const pagination = paginationMetaData();
  const alertText = sprintf(
    n__(
      'Single template on this page is selected.',
      'All %s templates on this page are selected.',
      pagination.perPage
    ),
    pagination.perPage
  );
  const selectText = sprintf(
    n__('Select this template', 'Select all<b> %s </b> templates', pagination.total),
    pagination.total
  );
  const multpleAlert = $('#multiple-alert');
  multpleAlert
    .find('.text')
    .html(
      `${alertText} <a href="#" onclick="tfm.templates.table.multipleSelection();">${selectText}</a>`
    );
  multpleAlert.data('multiple', false);
  $('.select_count').html(pagination.perPage);
}

export function toggleCheck() {
  const pagination = paginationMetaData();
  const multpleAlert = $('#multiple-alert');
  const checked = $('#check_all').is(':checked');
  $('.template_select_boxes').each((index, box) => {
    box.checked = checked;
    templateChecked(box);
  });
  if (checked && pagination.perPage - pagination.total < 0) {
    multpleAlert.show('slow');
    multpleAlert.data('multiple', false);
  } else if (!checked) {
    multpleAlert.hide('slow');
    multpleAlert.data('multiple', false);
    cleanTemplatesSelection();
  }
  return false;
}

export function toggleMultipleOkButton({ value }) {
  const btn = $('#confirmation-modal .btn-primary');
  if (value !== 'disabled') btn.removeClass('disabled').attr('disabled', false);
  else btn.addClass('disabled').attr('disabled', true);
}

export function submitModalForm() {
  if (!$('#keep_selected').is(':checked')) removeForemanTemplatesCookie();
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
    : { template_ids: foremanSelectedTemplates };
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
  if (foremanSelectedTemplates)
    $('.select_count').text(foremanSelectedTemplates.length);
  let title = '';
  if (item.prop('checked') && foremanSelectedTemplates)
    title = `${foremanSelectedTemplates.length} - ${item.attr('uncheck-title')}`;
  else title = item.attr('check-title');

  item.attr('data-original-title', title);
  item.tooltip({
    trigger: 'hover',
  });
  return false;
}
