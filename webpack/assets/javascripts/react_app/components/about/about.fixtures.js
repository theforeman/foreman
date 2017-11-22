export const data = {
  compute: [
    { id: { name: 'Libvirt', id: 1 }, type: 'Libvirt' },
    { id: { name: 'Ovirt', id: 2 }, type: 'Ovirt' },
  ],
  proxy: [
    {
      id: { name: 'regular', id: 1 },
      features: 'Facts, Logs, DNS, DHCP, and Puppet',
    },
  ],
  plugin: [
    {
      name: 'foreman_discovery',
      description: 'MaaS Discovery Plugin engine for Foreman',
      author:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ex ea difficultate illae fallaciloquae',
      version: '11.0.0',
    },
  ],
  provider: [
    { provider: 'Libvirt', status: true },
    { provider: 'oVirt', status: true },
    { provider: 'EC2', status: true },
    { provider: 'VMware', status: true },
    { provider: 'OpenStack', status: true },
    { provider: 'Rackspace', status: true },
    { provider: 'Google', status: true },
  ],
};
