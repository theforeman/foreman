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

/* eslint-disable max-statements, max-len */
describe('checkPXELoaderCompatibility', () => {
  function assertCompatibility(osTitle, pxeLoader) {
    it(osTitle + ' is compatible with ' + pxeLoader, () => {
      let result = hosts.checkPXELoaderCompatibility(osTitle, pxeLoader);

      expect(result).toEqual(true);
    });
  }

  function refuteCompatibility(osTitle, pxeLoader) {
    it(osTitle + ' is incompatible with ' + pxeLoader, () => {
      let result = hosts.checkPXELoaderCompatibility(osTitle, pxeLoader);

      expect(result).toEqual(false);
    });
  }

  function assertUndefinedCompatibility(osTitle, pxeLoader) {
    it(osTitle + ' has undefined compatibility with ' + pxeLoader, () => {
      let result = hosts.checkPXELoaderCompatibility(osTitle, pxeLoader);

      expect(result).toEqual(null);
    });
  }

  // RHEL 6.x and Grub1
  // RHEL 7.x and Grub2
  describe('RHEL', () => {
    assertUndefinedCompatibility('RHEL 5', 'PXELinux BIOS');
    assertUndefinedCompatibility('RHEL 5', 'PXELinux UEFI');
    assertUndefinedCompatibility('RHEL 5', 'Grub UEFI');
    assertUndefinedCompatibility('RHEL 5', 'Grub2 UEFI');
    assertUndefinedCompatibility('RHEL 5', 'Grub2 UEFI SecureBoot');

    assertCompatibility('RHEL 6.0', 'PXELinux BIOS');
    refuteCompatibility('RHEL 6.0', 'PXELinux UEFI');
    assertCompatibility('RHEL 6.0', 'Grub UEFI');
    refuteCompatibility('RHEL 6.0', 'Grub2 UEFI');
    refuteCompatibility('RHEL 6.0', 'Grub2 UEFI SecureBoot');

    assertCompatibility('Red Hat Enterprise Linux Server release 6.0 (Santiago)', 'PXELinux BIOS');
    refuteCompatibility('Red Hat Enterprise Linux Server release 6.0 (Santiago)', 'PXELinux UEFI');
    assertCompatibility('Red Hat Enterprise Linux Server release 6.0 (Santiago)', 'Grub UEFI');
    refuteCompatibility('Red Hat Enterprise Linux Server release 6.0 (Santiago)', 'Grub2 UEFI');
    refuteCompatibility('Red Hat Enterprise Linux Server release 6.0 (Santiago)', 'Grub2 UEFI SecureBoot');

    assertCompatibility('RHEL 7.0', 'PXELinux BIOS');
    refuteCompatibility('RHEL 7.0', 'PXELinux UEFI');
    refuteCompatibility('RHEL 7.0', 'Grub UEFI');
    assertCompatibility('RHEL 7.0', 'Grub2 UEFI');
    assertCompatibility('RHEL 7.0', 'Grub2 UEFI SecureBoot');

    assertCompatibility('RHEL 8.0', 'PXELinux BIOS');
    refuteCompatibility('RHEL 8.0', 'PXELinux UEFI');
    refuteCompatibility('RHEL 8.0', 'Grub UEFI');
    assertCompatibility('RHEL 8.0', 'Grub2 UEFI');
    assertCompatibility('RHEL 8.0', 'Grub2 UEFI SecureBoot');

    assertCompatibility('CentOS 7', 'PXELinux BIOS');
    refuteCompatibility('CentOS 7', 'PXELinux UEFI');
    refuteCompatibility('CentOS 7', 'Grub UEFI');
    assertCompatibility('CentOS 7', 'Grub2 UEFI');
    assertCompatibility('CentOS 7', 'Grub2 UEFI SecureBoot');
  });

  // Debian 2-6 and Grub1
  // Debian 7+ and Grub2
  describe('Debian', () => {
    assertCompatibility('Debian 6', 'PXELinux BIOS');
    refuteCompatibility('Debian 6', 'PXELinux UEFI');
    assertCompatibility('Debian 6', 'Grub UEFI');
    refuteCompatibility('Debian 6', 'Grub2 UEFI');
    refuteCompatibility('Debian 6', 'Grub2 UEFI SecureBoot');

    assertCompatibility('Debian 2', 'PXELinux BIOS');
    refuteCompatibility('Debian 2', 'PXELinux UEFI');
    assertCompatibility('Debian 2', 'Grub UEFI');
    refuteCompatibility('Debian 2', 'Grub2 UEFI');
    refuteCompatibility('Debian 2', 'Grub2 UEFI SecureBoot');

    assertCompatibility('Debian 7.0', 'PXELinux BIOS');
    refuteCompatibility('Debian 7.0', 'PXELinux UEFI');
    refuteCompatibility('Debian 7.0', 'Grub UEFI');
    assertCompatibility('Debian 7.0', 'Grub2 UEFI');
    assertCompatibility('Debian 7.0', 'Grub2 UEFI SecureBoot');

    assertUndefinedCompatibility('Debian', 'PXELinux BIOS');
    assertUndefinedCompatibility('Debian', 'PXELinux UEFI');
    assertUndefinedCompatibility('Debian', 'Grub UEFI');
    assertUndefinedCompatibility('Debian', 'Grub2 UEFI');
    assertUndefinedCompatibility('Debian', 'Grub2 UEFI SecureBoot');
  });

  // Ubuntu 10.x or older and Grub1
  // Ubuntu 11.x or newer and Grub2
  describe('Ubuntu', () => {
    assertCompatibility('Ubuntu 10.4', 'PXELinux BIOS');
    refuteCompatibility('Ubuntu 10.4', 'PXELinux UEFI');
    assertCompatibility('Ubuntu 10.4', 'Grub UEFI');
    refuteCompatibility('Ubuntu 10.4', 'Grub2 UEFI');
    refuteCompatibility('Ubuntu 10.4', 'Grub2 UEFI SecureBoot');

    assertCompatibility('Ubuntu 11.4', 'PXELinux BIOS');
    refuteCompatibility('Ubuntu 11.4', 'PXELinux UEFI');
    refuteCompatibility('Ubuntu 11.4', 'Grub UEFI');
    assertCompatibility('Ubuntu 11.4', 'Grub2 UEFI');
    assertCompatibility('Ubuntu 11.4', 'Grub2 UEFI SecureBoot');

    assertCompatibility('Ubuntu 11.10', 'PXELinux BIOS');
    refuteCompatibility('Ubuntu 11.10', 'PXELinux UEFI');
    refuteCompatibility('Ubuntu 11.10', 'Grub UEFI');
    assertCompatibility('Ubuntu 11.10', 'Grub2 UEFI');
    assertCompatibility('Ubuntu 11.10', 'Grub2 UEFI SecureBoot');

    assertUndefinedCompatibility('Ubuntu', 'PXELinux BIOS');
    assertUndefinedCompatibility('Ubuntu', 'PXELinux UEFI');
    assertUndefinedCompatibility('Ubuntu', 'Grub UEFI');
    assertUndefinedCompatibility('Ubuntu', 'Grub2 UEFI');
    assertUndefinedCompatibility('Ubuntu', 'Grub2 UEFI SecureBoot');
  });

  describe('unknown os', () => {
    assertUndefinedCompatibility('Unknown OS', 'PXELinux BIOS');
    assertUndefinedCompatibility('Unknown OS', 'PXELinux UEFI');
    assertUndefinedCompatibility('Unknown OS', 'Grub UEFI');
    assertUndefinedCompatibility('Unknown OS', 'Grub2 UEFI');
    assertUndefinedCompatibility('Unknown OS', 'Grub2 UEFI SecureBoot');
  });
});
