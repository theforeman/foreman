/* eslint-disable jquery/no-val */
/* eslint-disable jquery/no-find */
/* eslint-disable jquery/no-text */
/* eslint-disable jquery/no-ajax */
/* eslint-disable jquery/no-each */
/* eslint-disable jquery/no-class */

import $ from 'jquery';
import { sprintf, translate as __ } from './react_app/common/I18n';

import { showLoading, hideLoading } from './foreman_navigation';

import store from './react_app/redux';
import { openConfirmModal as coreOpenConfirmModal } from './react_app/components/ConfirmModal';

export const openConfirmModal = (options) =>
  store.dispatch(coreOpenConfirmModal(options));

export * from './react_app/common/DeprecationService';

export function showSpinner() {
  showLoading();
}

export function hideSpinner() {
  hideLoading();
}

export function iconText(name, innerText, iconClass) {
  let icon = `<span class="${iconClass} ${iconClass}-${name}"/>`;

  if (innerText !== '') {
    icon += `<strong>${innerText}</strong>`;
  }
  return icon;
}

export function activateDatatables() {
  const language = {
    searchPlaceholder: __('Filter...'),
    emptyTable: __('No data available in table'),
    info: sprintf(
      __('Showing %s to %s of %s entries'),
      '_START_',
      '_END_',
      '_TOTAL_'
    ),
    infoEmpty: __('Showing 0 to 0 of 0 entries'),
    infoFiltered: sprintf(__('(filtered from %s total entries)'), '_MAX_'),
    lengthMenu: sprintf(__('Show %s entries'), '_MENU_'),
    loadingRecords: __('Loading...'),
    processing: __('Processing...'),
    search: __('Search:'),
    zeroRecords: __('No matching records found'),
    paginate: {
      first: __('First'),
      last: __('Last'),
      next: __('Next'),
      previous: __('Previous'),
    },
    aria: {
      sortAscending: __(': activate to sort column ascending'),
      sortDescending: __(': activate to sort column descending'),
    },
  };
  $('[data-table=inline]').not('.dataTable').DataTable({
    language,
    dom: "<'row'<'col-md-6'f>r>t<'row'<'col-md-6'i><'col-md-6'p>>",
  });

  $('[data-table=server]')
    .not('.dataTable')
    .each((i, el) => {
      const url = el.getAttribute('data-source');

      $(el).DataTable({
        language,
        processing: true,
        serverSide: true,
        ordering: false,
        ajax: url,
        dom: "<'row'<'col-md-6'f>r>t<'row'<'col-md-6'><'col-md-6'p>>",
      });
    });
}

export function activateTooltips(elParam = 'body') {
  const el = $(elParam);

  el.tooltip({
    selector: '[rel="twipsy"],*[title]:not(*[rel],.fa,.pficon)',
    container: 'body',
    trigger: 'hover',
  });
  // Ellipsis have to be initialized for each element for title() to work
  el.find('.ellipsis').tooltip({
    container: 'body',
    title() {
      return this.scrollWidth > this.clientWidth ? this.textContent : null;
    },
  });
}

export function initTypeAheadSelect(input) {
  input.select2({
    ajax: {
      url: input.data('url'),
      dataType: 'json',
      quietMillis: 250,
      data: (term, page) => ({
        q: term,
        scope: input.data('scope'),
      }),
      results: (data) => ({
        results: data.map(({ id, name }) => ({ id, text: name })),
      }),
      cache: true,
    },
    initSelection(element, callback) {
      $.ajax(input.data('url'), {
        data: {
          scope: input.data('scope'),
        },
        dataType: 'json',
      }).done((data) => {
        if (data.length > 0) {
          // eslint-disable-next-line standard/no-callback-literal
          callback({ id: data[0].id, text: data[0].name });
        }
      });
    },
    width: '400px',
  });
}

// generates an absolute, needed in case of running Foreman from a subpath
export { foremanUrl } from './react_app/common/helpers';

export const setTab = () => {
  const urlHash = document.location.hash.split('?')[0];
  if (urlHash.length) {
    const tabContent = $(urlHash);
    const parentTab = tabContent.closest('.tab-pane');
    if (parentTab.exists()) {
      $(`.nav-tabs a[href="#${parentTab[0].id}"]`).tab('show');
    }
    $(`.nav-tabs a[href="${urlHash}"]`).tab('show');
  }
};

export function highlightTabErrors() {
  const errorFields = $('.tab-content .has-error');
  errorFields.parents('.tab-pane').each(function fn() {
    $(`a[href="#${this.id}"]`).addClass('tab-error');
  });
  $('.tab-error').first().click();
  $('.nav-pills .tab-error').first().click();
  errorFields.first().find('.form-control').focus();
}
