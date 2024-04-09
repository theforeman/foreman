# Be sure to restart your server when you modify this file.
# This inflector is used as a workaround for inconsistent acronym usage in constants.
Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    'dns_interface' => 'DnsInterface',
    'proxy_api' => 'ProxyAPI',
    'ssh_provision' => 'SSHProvision',
    'external_ipam' => 'ExternalIpam'
  )
end
# Add new inflection rules using the following format
# (all these examples are active by default):
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'AAAA' # DNS IPv6 record
  inflect.acronym 'AIX' # IBM AIX
  inflect.acronym 'AWS' # Amazon Web Services
  inflect.acronym 'BMC' # Baseboard Management Controller
  inflect.acronym 'CA' # Certificate Authority
  inflect.acronym 'DHCP' # Dynamic Host Configuration Protocol
  inflect.acronym 'DNS' # Domain Name System
  inflect.acronym 'EC2' # Amazon Elastic Compute Cloud
  inflect.acronym 'IPAM' # IP Address Management
  inflect.acronym 'NXOS' # Cisco NX-OS
  inflect.acronym 'PTR' # DNS reverse DNS record\
  # Causes an overlap between ::SSHKey and the SshKey model
  # It seems acronyms have a lot of weird power in constant lookups,
  # so ssh_key will be always looked up as SSHKey, which is not a Foreman's model
  # inflect.acronym 'SSH' # Secure SHell
  inflect.acronym 'SSO' # Single Sign On
  inflect.acronym 'STI' # Single Table Inheritance
  inflect.acronym 'TFTP' # Trivial File Transfer Protocol
  inflect.acronym 'UI' # User Interface
  inflect.acronym 'URL' # Uniform Resource Locator
  inflect.acronym 'VRP' # Huawei VRP
  inflect.acronym 'ZTP' # Zero Touch Provisioning
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
