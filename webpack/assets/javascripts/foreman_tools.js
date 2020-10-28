/* eslint-disable jquery/no-val */
/* eslint-disable jquery/no-find */
/* eslint-disable jquery/no-text */
/* eslint-disable jquery/no-ajax */
/* eslint-disable jquery/no-each */

import $ from 'jquery';
import URI from 'urijs';
import { translate as __ } from './react_app/common/I18n';
import { deprecate } from './react_app/common/DeprecationService';

import { showLoading, hideLoading, visit } from './foreman_navigation';

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
  $('[data-table=inline]')
    .not('.dataTable')
    .DataTable({
      language: {
        searchPlaceholder: __('Filter...'),
      },
      dom: "<'row'<'col-md-6'f>r>t<'row'<'col-md-6'i><'col-md-6'p>>",
    });

  $('[data-table=server]')
    .not('.dataTable')
    .each((i, el) => {
      const url = el.getAttribute('data-source');

      $(el).DataTable({
        language: {
          searchPlaceholder: __('Filter...'),
        },
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
  el.find('[rel="twipsy"]').tooltip({ container: 'body' });
  el.find('.ellipsis').tooltip({
    container: 'body',
    title() {
      return this.scrollWidth > this.clientWidth ? this.textContent : null;
    },
  });
  el.find('*[title]')
    .not('*[rel],.fa,.pficon')
    .tooltip({ container: 'body' });
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
      results: data => ({
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
      }).done(data => {
        if (data.length > 0) {
          // eslint-disable-next-line standard/no-callback-literal
          callback({ id: data[0].id, text: data[0].name });
        }
      });
    },
    width: '400px',
  });
}

// handle table updates via turoblinks
export function updateTable(element) {
  deprecate('updateTable', 'react Table component', '2.1');
  const uri = new URI(window.location.href);

  const values = {};

  if (['per_page', 'search-form'].includes(element.id)) {
    values.page = '1';
  } else {
    values.page = $('#cur_page_num').val();
  }

  const searchTerm = $(element)
    .find('.autocomplete-input')
    .val();
  if (searchTerm !== undefined) {
    values.search = searchTerm.trim();
  }
  values.per_page = $('#pagination-row-dropdown')
    .text()
    .trim();
  uri.setSearch(values);

  visit(uri.toString());
  return false;
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
