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
      },
      dom: "<'row'<'col-md-6'f>r>t<'row'<'col-md-6'><'col-md-6'p>>",
    });
  });
});

describe('activateTooltips', () => {
  it('calls $.fn.tooltip on all matching elements', () => {
    const elements = `<div rel='twipsy'></div>
      <div class='ellipsis'></div>
      <div title='test'></div>
      <div title='test' rel='popover'></div>`;

    $.fn.tooltip = jest.fn();
    tools.activateTooltips(elements);
    expect($.fn.tooltip).toHaveBeenCalledTimes(3);
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

/* eslint-disable max-statements */
describe('initTypeAheadSelect', () => {
  it('initializes select2 on given input field', () => {
    document.body.innerHTML =
      '<input type="text" id="typeahead" data-url="testurl" data-scope="testscope">';

    const field = $('#typeahead');

    $.ajax = jest.fn(url => {
      const ajaxMock = $.Deferred();

      ajaxMock.resolve([
        { id: 1, name: 'testoption' },
        { id: 2, name: 'anotheroption' },
      ]);
      return ajaxMock.promise();
    });

    tools.initTypeAheadSelect(field);
    $('.select2-choice').trigger('mousedown');
    $('.select2-choice').trigger('mouseup');
    expect(document.body.innerHTML).toContain('select2-container');
    expect($('.select2-chosen').text()).toEqual('testoption');
  });
});

describe('updateTableTest', () => {
  beforeEach(() => {
    global.tfm = {
      tools,
    };
    document.body.innerHTML = `
<div>
    <form id="search-form" onsubmit="return tfm.tools.updateTable(this);" action="/templates/provisioning_templates" accept-charset="UTF-8" method="get"><input name="utf8" type="hidden" value="✓">
  <div class="input-group">
    <input type="text" name="search" id="search" value="name = y " placeholder="Filter ..." class="autocomplete-input form-control ui-autocomplete-input ui-autocomplete-loading" data-url="/templates/provisioning_templates/auto_complete_search" autocomplete="off"><a class="autocomplete-clear" tabindex="-1" title="" data-original-title="Clear" style="display: none;">×</a>
    <span class="input-group-btn">
      <button class="btn btn-default" type="submit">
        <span class="glyphicon glyphicon-search "></span> <span class="hidden-xs">Search</span>
      </button>
      <button class="btn btn-default dropdown-toggle" data-toggle="dropdown">
        <span class="caret"></span>
      </button>
      <ul class="dropdown-menu pull-right">
        <li class="divider"></li>
        <li><a id="bookmark" data-url="/bookmarks/new?kontroller=provisioning_templates" href="#" onclick="$('#bookmarks-modal').modal();; return false;">Bookmark this search</a></li>
        <li><a rel="external noopener noreferrer" target="_blank" href="http://www.theforeman.org/manuals/1.16/index.html#4.1.5Searching"><span class="glyphicon glyphicon-question-sign icon-black"></span> Documentation</a></li>
      </ul>
    </span>
  </div>
</form>
<table></table>
<form onsubmit="return tfm.tools.updateTable(this);" class="content-view-pf-pagination table-view-pf-pagination paginate" id="pagination" data-count="7" data-per-page="7">
  <div class="form-group">
    <select name="per_page" id="per_page" label="per page" onchange="tfm.tools.updateTable(this)" class="pagination-pf-pagesize without_select2 per-page"><option selected="selected" value="5">5</option>
<option value="10">10</option>
<option value="15">15</option>
<option value="20">20</option>
<option value="25">25</option>
<option value="50">50</option></select>
    <span>per page</span>
  </div>

  <div class="form-group">
    <span>
      <span class="pagination-pf-items-current">
        1-5
      </span>
      of
      <span class="pagination-pf-items-total">
        7
      </span>
    </span>
    <ul class="pagination pagination-pf-back"><li class="firs first_page disabled"><a href="#"><span class="fa fa-angle-double-left "></span> </a></li><li class="prev previous_page disabled"><a href="#"><span class="fa fa-angle-left "></span> </a></li></ul> <input class="pagination-pf-page" type="text" value="1" id="cur_page_num"><label class="sr-only" for="cur_page_num">Current Page</label><span>of <span class="pagination-pf-pages">2</span></span> <ul class="pagination pagination-pf-forward"><li class="next next_page "><a rel="next" href="/hosts?page=2&amp;per_page=5&amp;search=environment+%3D++testing"><span class="fa fa-angle-right "></span> </a></li><li class="last last_page "><a rel="next" href="/hosts?page=2&amp;per_page=5&amp;search=environment+%3D++testing"><span class="fa fa-angle-double-right "></span> </a></li></ul>
  </div>
</form>
</div>
    `;
  });

  it('should use selected per page value and add it to the url considering search term and pagination', () => {
    const PerPage = $('#pagination-row-dropdown')
      .text()
      .trim();

    $('#search-form').submit();
    expect(visit).toHaveBeenCalledWith(
      `http://localhost/?page=1&search=name+%3D+y&per_page=${PerPage}`
    );
  });

  it('should change page', () => {
    const PerPage = $('#pagination-row-dropdown')
      .text()
      .trim();

    $('#cur_page_num').val('4');
    $('#pagination').submit();
    expect(visit).toHaveBeenCalledWith(
      `http://localhost/?page=4&per_page=${PerPage}`
    );
  });

  it('should use find search term and add it to the url considering per page value and pagination', () => {
    const PerPage = $('#pagination-row-dropdown')
      .text()
      .trim();
    $('#search-form').submit();
    expect(visit).toHaveBeenCalledWith(
      `http://localhost/?page=1&search=name+%3D+y&per_page=${PerPage}`
    );
  });

  it('should reset page param to 1 after new search', () => {
    const PerPage = $('#pagination-row-dropdown')
      .text()
      .trim();

    window.history.pushState({}, 'Test Title', '/?page=4');
    $('.autocomplete-input').val('test');
    $('#search-form').submit();
    expect(visit).toHaveBeenCalledWith(
      `http://localhost/?page=1&search=test&per_page=${PerPage}`
    );
  });

  it('should remove search param if search is empty', () => {
    ['', ' '].map(searchValue => {
      const PerPage = $('#pagination-row-dropdown')
        .text()
        .trim();
      $('.autocomplete-input').val(searchValue);
      $('#search-form').submit();
      return expect(visit).toHaveBeenCalledWith(
        `http://localhost/?page=1&search=&per_page=${PerPage}`
      );
    });
  });

  it('deprecateObjectProperty should depracte an object property', () => {
    const obj = { deprecated: jest.fn() };
    console.warn = jest.fn();

    tools.deprecateObjectProperty(obj, 'deprecated', 'tfm.obj', '1.42');
    obj.deprecated();
    expect(console.warn).toHaveBeenCalledWith(
      'DEPRECATION WARNING: you are using deprecated deprecated, it will be removed in Foreman 1.42. Use tfm.obj instead.'
    );
  });
});
