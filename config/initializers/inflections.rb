# Be sure to restart your server when you modify this file.

Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    'proxy_api' => 'ProxyAPI'
  )
end

# Add new inflection rules using the following format
# (all these examples are active by default):
ActiveSupport::Inflector.inflections do |inflect|
  # Requires our entire Api namespace to be rewritten
  # inflect.acronym 'API'
  inflect.acronym 'AIX'
  inflect.acronym 'AWS'
  inflect.acronym 'BMC'
  inflect.acronym 'CA'
  inflect.acronym 'DHCP'
  inflect.acronym 'DNS'
  inflect.acronym 'EC2'
  inflect.acronym 'GCE'
  inflect.acronym 'IPAM'
  inflect.acronym 'NXOS'
  # Causes an overlap between ::SSHKey and the SshKey model
  # inflect.acronym 'SSH'
  inflect.acronym 'SSO' # Single Sign On
  inflect.acronym 'STI'
  inflect.acronym 'TFTP' # Trivial File Transfer Protocol
  inflect.acronym 'UI'
  inflect.acronym 'VRP'
  inflect.acronym 'URL'
  inflect.acronym 'ZTP'
  inflect.acronym 'AAAA' # DNS IPv6 record
  inflect.acronym 'PTR' # DNS reverse DNS record

  # inflect.plural /^(ox)$/i, '\1en'
  # inflect.singular /^(ox)en/i, '\1'
  # inflect.irregular 'person', 'people'
  # inflect.uncountable %w( fish sheep )
  inflect.singular /^puppetclass$/, 'puppetclass'
  inflect.singular /^Puppetclass$/, 'Puppetclass'
  inflect.singular /^HostClass$/, 'HostClass'
  inflect.singular /^host_class$/, 'host_class'
  inflect.singular /^HostgroupClass$/, 'HostgroupClass'
  inflect.singular /^hostgroup_class$/, 'hostgroup_class'
end
