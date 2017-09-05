jest.unmock('./foreman_hosts');
const hosts = require('./foreman_hosts');

describe('getAttributesToPost', () => {
    beforeEach(() => {
      window.tfm = {hosts: {pluginEditAttributes: {}}};
  });

  it('attribute hash holds the default attributes', () => {
    let ret = hosts.getAttributesToPost('os');

    expect(ret).toEqual(['operatingsystem_id', 'organization_id', 'location_id']);
  });

  it('adds the plugin_edit_attributes', () => {
    hosts.registerPluginAttributes('os', ['foo']);
    expect(hosts.getAttributesToPost('os')).toEqual(
                 ['operatingsystem_id', 'organization_id', 'location_id', 'foo']);
  });

});
