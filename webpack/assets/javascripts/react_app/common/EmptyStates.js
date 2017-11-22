export const computeResource = () => ({
  header: __('Compute Resource'),
  description: __('Foreman supports creating and managing hosts on a number of virtualization and cloud services - referred to as “compute resources” - as well as bare metal hosts.'),
  documentation: {
    // eslint-disable-next-line no-undef
    url: `https://www.theforeman.org/manuals/${VERSION}/index.html#5.2ComputeResources`,
  },
  action: {
    title: __('Create a compute resource'),
    url: '/compute_resources/new',
  },
});

export const plugin = () => ({
  header: __('Plugin'),
  description: __('Plugins are tools to extend and modify the functionality of Foreman. Plugins offer custom functions and features so that each user can tailor their environment to their specific needs.'),
  documentation: {
    // eslint-disable-next-line no-undef
    url: `https://www.theforeman.org/manuals/${VERSION}/index.html#Plugins`,
  },
  action: {
    title: __('Get a plugin'),
    url: 'https://projects.theforeman.org/projects/foreman/wiki/List_of_Plugins',
  },
});

export const smartProxy = () => ({
  header: __('Smart Proxy'),
  description: __('The Smart Proxy provides an easy way to add or extended existing subsystems, via DHCP, DNS, Puppet, etc.'),
  documentation: {
    // eslint-disable-next-line no-undef
    url: `https://www.theforeman.org/manuals/${VERSION}/index.html#Smart-Proxy`,
  },
  action: {
    title: __('Create a smart proxy'),
    url: '/smart_proxies/new',
  },
});
