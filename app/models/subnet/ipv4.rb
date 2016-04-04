require 'socket'

class Subnet::Ipv4 < Subnet
  def self.default_sti_class
    'Subnet::Ipv4'
  end

  has_many :interfaces, :class_name => 'Nic::Base', :foreign_key => :subnet_id
  has_many :primary_interfaces, -> { where(:primary => true) }, :class_name => 'Nic::Base', :foreign_key => :subnet_id
  has_many :hosts, :through => :interfaces
  has_many :primary_hosts, :through => :primary_interfaces, :source => :host

  validates :mask, :format => {:with => Net::Validations::MASK_REGEXP}

  def family
    Socket::AF_INET
  end

  def in_mask
    IPAddr::IN4MASK
  end

  def validate_ip(ip)
    Net::Validations.validate_ip(ip)
  end

  def self.supported_ipam_modes
    [:dhcp, :db, :none]
  end

  private

  def cleanup_ip(address)
    super
    address.gsub!(/2555+/, "255")
    address
  end

  def normalize_ip(address)
    Net::Validations.normalize_ip(address)
  end
end
