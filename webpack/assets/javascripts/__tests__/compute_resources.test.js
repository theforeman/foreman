jest.unmock('../compute_resources.js');
const computeResources = require('../compute_resources.js');

describe('setFieldError', () => {
  it('adds an error message', () => {
    const $ = require('jquery');

    document.body.innerHTML = '<div class="form-group"><label for="name">Example</label><div>' +
      '<input type="text" id="example" /><span class="help-block"></span>' +
      '</div><span class="help-block help-inline">Explanation.</span></div></div>';

    computeResources.setFieldError($('#example'), 'Errormsg');

    expect(document.body.innerHTML)
    .toBe('<div class="form-group has-error"><label for="name">Example</label><div>' +
        '<input type="text" id="example"><span class="help-block"></span></div>' +
        '<span class="help-block help-inline">' +
        '<span class="error-message">Errormsg</span>Explanation.</span></div>');
  });
});

describe('clearFieldError', () => {
  it('clears an message', () => {
    const $ = require('jquery');

    document.body.innerHTML = '<div class="form-group has-error">' +
      '<label for="name">Example</label><div>' +
      '<input type="text" id="example"><span class="help-block"></span></div>' +
      '<span class="help-block help-inline">' +
      '<span class="error-message">Errormsg</span>Explanation.</span></div>';

    computeResources.clearFieldError($('#example'));

    expect(document.body.innerHTML)
    .toBe('<div class="form-group"><label for="name">Example</label>' +
        '<div><input type="text" id="example"><span class="help-block"></span>' +
        '</div><span class="help-block help-inline">Explanation.</span></div>');
  });
});

describe('datastoreStats', () => {
  it('formats stats to a proper label with stats data', () => {

    window.Jed = {sprintf: (source, obj) => {
      return source.replace('%(name)s', obj.name)
        .replace('%(free)s', obj.free)
        .replace('%(prov)s', obj.prov)
        .replace('%(total)s', obj.total);
    }};
    window.__ = (str) => {return str;};

    let datastore = {
      name: 'Test',
      free: '1024',
      prov: '2048',
      total: '3072'
    };

    expect(computeResources.datastoreStats(datastore))
    .toBe('Test (free: 1024 prov: 2048 total: 3072)');
  });

  it('formats a datastore object to name without stat data', () => {
    let datastore = {
      name: 'Test'
    };

    expect(computeResources.datastoreStats(datastore))
    .toBe('Test');
  });
});
