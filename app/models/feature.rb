class Feature < ActiveRecord::Base
  has_and_belongs_to_many :smart_proxies
  validates :name, :presence => true

  NAME_MAP = {
    'tftp'     => 'TFTP',
    'bmc'      => 'BMC',
    'dns'      => 'DNS',
    'dhcp'     => 'DHCP',
    'puppetca' => 'Puppet CA',
    'puppet'   => 'Puppet'
  }

end
