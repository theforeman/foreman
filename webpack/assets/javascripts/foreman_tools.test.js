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
    tools.activateTooltips($(elements));
    expect($.fn.tooltip).toHaveBeenCalledTimes(3);
  });
});
