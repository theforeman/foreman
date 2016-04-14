require 'socket'

class Subnet::Ipv4 < Subnet
  has_many :interfaces, :class_name => 'Nic::Base', :foreign_key => :subnet_id
  has_many :primary_interfaces, -> { where(:primary => true) }, :class_name => 'Nic::Base', :foreign_key => :subnet_id
  # The has_many :through associations below have to be defined after the
  # corresponding has_many associations and thus can not be defined in the parent class
  has_many :hosts, :through => :interfaces
  has_many :primary_hosts, :through => :primary_interfaces, :source => :host

  validates :mask, :format => {:with => Net::Validations::MASK_REGEXP}

  before_validation :cleanup_addresses

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

  def cleanup_addresses
    IP_FIELDS.each do |f|
      send("#{f}=", cleanup_ip(send(f))) if send(f).present?
    end
    self
  end

  private

  def cleanup_ip(address)
    address.gsub!(/\.\.+/, ".")
    address.gsub!(/2555+/, "255")
    address
  end

  def normalize_ip(address)
    Net::Validations.normalize_ip(address)
  end
end
