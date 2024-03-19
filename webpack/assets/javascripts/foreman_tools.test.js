/* eslint-disable jquery/no-val */
/* eslint-disable jquery/no-submit */
/* eslint-disable jquery/no-deferred */
/* eslint-disable jquery/no-trigger */
/* eslint-disable jquery/no-text */
/* eslint-disable jquery/no-data */

import $ from 'jquery';
import 'select2';
import { visit } from './foreman_navigation';
import * as tools from './foreman_tools';

jest.unmock('jquery');
jest.unmock('./foreman_tools');

describe('iconText', () => {
  it('creates a label with the right icon class', () => {
    expect(tools.iconText('plus', '', 'patternfly')).toBe(
      '<span class="patternfly patternfly-plus"/>'
    );
  });

  it('adds a bold text next to the label', () => {
    expect(tools.iconText('plus', 'foo', 'patternfly')).toBe(
      '<span class="patternfly patternfly-plus"/><strong>foo</strong>'
    );
  });
});

describe('activateDatatables', () => {
  it('calls $.fn.DataTable when it finds a data-table=server', () => {
    // Used for rendering lists of VMs under compute resources
    document.body.innerHTML = `<div data-table=server data-source=http://example.foo>
      To be filled by a table
      </div>`;
    $.fn.DataTable = jest.fn();
    tools.activateDatatables();
    expect($.fn.DataTable).toBeCalledWith({
      processing: true,
      serverSide: true,
      ordering: false,
      ajax: $('[data-table=server]').data('source'),
      language: {
        searchPlaceholder: 'Filter...',
        emptyTable: 'No data available in table',
        info: 'Showing _START_ to _END_ of _TOTAL_ entries',
        infoEmpty: 'Showing 0 to 0 of 0 entries',
        infoFiltered: '(filtered from _MAX_ total entries)',
        lengthMenu: 'Show _MENU_ entries',
        loadingRecords: 'Loading...',
        processing: 'Processing...',
        search: 'Search:',
        zeroRecords: 'No matching records found',
        paginate: {
          first: 'First',
          last: 'Last',
          next: 'Next',
          previous: 'Previous',
        },
        aria: {
          sortAscending: ': activate to sort column ascending',
          sortDescending: ': activate to sort column descending',
        },
      },
      dom: "<'row'<'col-md-6'f>r>t<'row'<'col-md-6'><'col-md-6'p>>",
    });
  });
});

/* eslint-disable no-console, max-len */
describe('deprecate', () => {
  it('Logs the correct deprecation message', () => {
    console.warn = jest.fn();
    tools.deprecate('oldtest', 'tfm.tools.newtest', '1.42');
    expect(console.warn).toHaveBeenCalledWith(
      'DEPRECATION WARNING: you are using deprecated oldtest, it will be removed in Foreman 1.42. Use tfm.tools.newtest instead.'
    );
  });
});
