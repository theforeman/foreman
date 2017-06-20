jest.unmock('./foreman_tools');
const tools = require('./foreman_tools');

describe('iconText', () => {
  it('creates a label with the right icon class', () => {
    expect(tools.iconText('plus', '', 'patternfly'))
    .toBe('<span class="patternfly patternfly-plus"/>');
  });

  it('adds a bold text next to the label', () => {
    expect(tools.iconText('plus', 'foo', 'patternfly'))
    .toBe('<span class="patternfly patternfly-plus"/><strong>foo</strong>');
  });
});

describe('activateDatatables', () => {
  it('calls $.fn.DataTable when it finds a data-table=server', () => {
    const $ = require('jquery');

    // Used for rendering lists of VMs under compute resources
    document.body.innerHTML =
      `<div data-table=server data-source=http://example.foo>
      To be filled by a table
      </div>`;
    $.fn.DataTable = jest.fn();
    tools.activateDatatables();
    expect($.fn.DataTable).toBeCalledWith({
      processing: true,
      serverSide: true,
      ordering: false,
      ajax: $('[data-table=server]').data('source'),
      dom: "<'row'<'col-md-6'f>r>t<'row'<'col-md-6'><'col-md-6'p>>"
    });
  });
});

describe('activateTooltips', () => {
  it('calls $.fn.tooltip on all matching elements', () => {
    const $ = require('jquery');
    const elements =
      `<div rel='twipsy'></div>
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
    expect(console.warn).toHaveBeenCalledWith('DEPRECATION WARNING: you are using deprecated oldtest, it will be removed in Foreman 1.42. Use tfm.tools.newtest instead.');
  });
});

/* eslint-disable max-statements */
describe('initTypeAheadSelect', () => {
  it('initializes select2 on given input field', () => {
    const $ = require('jquery');

    require('select2');

    document.body.innerHTML =
      '<input type="text" id="typeahead" data-url="testurl" data-scope="testscope">';

    let field = $('#typeahead');

    $.ajax = jest.fn((url) => {
      let ajaxMock = $.Deferred();

      ajaxMock.resolve([{'id': 1, 'name': 'testoption'}, {'id': 2, 'name': 'anotheroption'}]);
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
    global.Turbolinks = {
      visit: jest.fn()
    };

    global.tfm = {
      tools: tools
    };

    Object.defineProperty(window.location, 'href', {
      writable: true,
      value: 'http://localhost'
    });
    document.body.innerHTML = `
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
        <li><a rel="external" target="_blank" data-id="aid_manuals_1.16_index.html" href="http://www.theforeman.org/manuals/1.16/index.html#4.1.5Searching"><span class="glyphicon glyphicon-question-sign icon-black"></span> Documentation</a></li>
      </ul>
    </span>
  </div>
</form>
    `;
  });

  it('should use turoblinks', () => {
    tools.updateTable();
    expect(global.Turbolinks.visit).toBeCalled();
  });

  it('should use find search term and add it to the url', () => {
    $('form').submit();
    expect(global.Turbolinks.visit).toHaveBeenLastCalledWith('http://localhost/?search=name+%3D+y');
  });
});
