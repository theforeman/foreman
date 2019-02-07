import $ from 'jquery';

import { activateTooltips } from './foreman_tools';
import { mount as reactMount } from './react_app/common/MountingService';
import { translate as __ } from './react_app/common/I18n';

export function filterLogsByMessage(expression) {
  const table = $('#table-proxy-status-logs').DataTable();

  filterLogsReset();
  changeFilterSelection(1);
  table
    .column(1)
    .search('ERROR|FATAL', true, false)
    .draw();
  table
    .column(2)
    .search(expression, true, false)
    .draw();
}

export function changeFilterSelection(index) {
  const filter = $('#logs-filter');
  filter[0].options[index].selected = true;
  filter.trigger('change');
  filterLogsByLevel(filter.val());
}

function filterLogsReset() {
  const table = $('#table-proxy-status-logs').DataTable();
  table.search('').draw();
}

function filterLogsByLevel(filter) {
  const table = $('#table-proxy-status-logs').DataTable();
  filterLogsReset();
  table
    .column(1)
    .search(filter, true, false)
    .draw();
}

export function activateLogsDataTable() {
  const domRootQuery = '#table-proxy-status-logs';

  _activateDataTable(domRootQuery);
  _activateFilter();
  _setupModal();
  // Activate tooltips for fields with ellipsis
  activateTooltips(domRootQuery);
}

export function expireLogs(item, from) {
  const tableUrl = item.getAttribute('data-url');
  const errorsUrl = item.getAttribute('data-url-errors');
  const modulesUrl = item.getAttribute('data-url-modules');
  if (tableUrl && errorsUrl && modulesUrl) {
    _ajaxExpireRequest(item, tableUrl, {
      type: 'POST',
      data: `from=${from}`,
      success: result => {
        $('#logs').html(result);
        activateLogsDataTable();
      },
    });
    _ajaxExpireRequest(item, errorsUrl, {
      success: result => {
        $('#ajax-errors-card').html(result);
      },
    });
    _ajaxExpireRequest(item, modulesUrl, {
      success: result => {
        $('#ajax-modules-card').html(result);
      },
    });
  }
}

function _mountReactShortTime($el) {
  reactMount(
    'ShortDateTime',
    `#${$el.attr('id')}`,
    { date: $el.data('time'), defaultValue: __('N/A'), seconds: false },
    true
  );
}

function _activateDataTable(domRootQuery) {
  $(domRootQuery).DataTable({
    dom: "<'row'<'col-md-6'f>r>t<'row'<'col-md-6'i><'col-md-6'p>>",
    autoWidth: false,
    columnDefs: [
      {
        render: (data, type, row) => data,
        width: '15%',
        targets: 0,
      },
      {
        width: '10%',
        targets: 1,
      },
    ],
    initComplete: (settings, jsonData) => {
      $(`${domRootQuery} .shorttime`).each((idx, el) => {
        _mountReactShortTime($(el));
      });
    },
  });
}

function _activateFilter() {
  const filter = $('#logs-filter');
  window.activate_select2(filter);
  filter.on('change', evt => {
    filterLogsByLevel(filter.val());
  });
}

function _setupModal() {
  $('#logEntryModal').on('show.bs.modal', event => {
    const link = $(event.relatedTarget);
    const modal = $(this);
    const datetime = link.data('time');
    const utcDatetime = link.data('utc-time');

    modal.find('#modal-bt-timegmt').text(utcDatetime);
    modal.find('#modal-bt-time').text(datetime);
    modal.find('#modal-bt-level').text(link.data('level'));
    if (link.data('message'))
      modal.find('#modal-bt-message').text(link.data('message'));
    if (link.data('backtrace'))
      modal.find('#modal-bt-backtrace').text(link.data('backtrace'));
  });
}

function _ajaxExpireRequest(item, url, opts = {}) {
  $.ajax({
    type: 'GET',
    url,
    complete: () => {
      window.reloadOnAjaxComplete(item);
    },
    ...opts,
  });
}
