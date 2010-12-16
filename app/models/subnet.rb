require 'ipaddr'
class Subnet < ActiveRecord::Base
  include Authorization
  has_many :hosts
  # sps = Service processors / ilom boards etc
  has_many :sps, :class_name => "Host", :foreign_key => 'sp_subnet_id'
  belongs_to :dhcp, :class_name => "SmartProxy"
  belongs_to :tftp, :class_name => "SmartProxy"
  belongs_to :domain
  validates_presence_of   :network, :mask, :domain_id, :name
  validates_uniqueness_of :network
  validates_format_of     :network, :with  => (/(\d{1,3}\.){3}\d{1,3}/)
  validates_format_of     :mask,    :with  => (/(\d{1,3}\.){3}\d{1,3}/)
  validates_uniqueness_of :name,    :scope => :domain_id
  default_scope :order => 'priority'

  before_destroy Ensure_not_used_by.new(:hosts, :sps)

  # Subnets are displayed in the form of their network network/network mask
  def to_label
    "#{network}/#{cidr}"
  end

  # Subnets are sorted on their priority value
  # [+other+] : Subnet object with which to compare ourself
  # +returns+ : Subnet object with higher precedence
  def <=> (other)
    self.priority <=> other.priority
  end

  # Given an IP returns the subnet that contains that IP
  # [+ip+] : "doted quad" string
  # Returns : Subnet object or nil if not found
  def self.subnet_for(ip)
    Subnet.all.each {|s| return s if s.contains? IPAddr.new(ip)}
    nil
  end

  # Indicates whether the IP is within this subnet
  # [+ip+] String: Contains 4 dotted decimal values
  # Returns Boolean: True if if ip is in this subnet
  def contains? ip
    IPAddr.new("#{network}/#{mask}", Socket::AF_INET).include? IPAddr.new(ip, Socket::AF_INET)
  end

  def cidr
    IPAddr.new(mask).to_i.to_s(2).count("1")
  end

  def dhcp_proxy
    dhcp and dhcp.url ? ProxyAPI::DHCP.new(:url => dhcp.url) : nil
  end

  def unused_ip
    if d=dhcp_proxy
      return d.unused_ip(network)["ip"]
    else
      nil
    end
  rescue => e
    logger.warn "failed to fetch a free IP from our proxy: #{e}"
    nil
  end

end
