require 'ipaddr'
class Subnet < ActiveRecord::Base
  include Authorization
  has_many :hosts
  # sps = Service processors / ilom boards etc
  has_many :sps, :class_name => "Host", :foreign_key => 'sp_subnet_id'
  belongs_to :dhcp, :class_name => "SmartProxy"
  belongs_to :tftp, :class_name => "SmartProxy"
  belongs_to :dns,  :class_name => "SmartProxy"
  has_many :subnet_domains, :dependent => :destroy
  has_many :domains, :through => :subnet_domains
  validates_presence_of   :network, :mask, :name
  validates_associated    :subnet_domains
  validates_uniqueness_of :network
  validates_format_of     :network, :mask,                        :with => Net::Validations::IP_REGEXP
  validates_format_of     :gateway, :dns_primary, :dns_secondary, :with => Net::Validations::IP_REGEXP, :allow_blank => true, :allow_nil => true
  validate :name_should_be_uniq_across_domains
  default_scope :order => 'priority'
  validate :validate_ranges

  has_many :taxonomy_subnet, :dependent => :destroy
  has_many :taxonomies, :through => :taxonomy_subnet

  before_destroy EnsureNotUsedBy.new(:hosts, :sps)

  scoped_search :on => [:name, :network, :mask, :gateway, :dns_primary, :dns_secondary, :vlanid], :complete_value => true
  scoped_search :in => :domains, :on => :name, :rename => :domain, :complete_value => true

  class Jail < ::Safemode::Jail
    allow :name, :network, :mask, :cidr, :title, :to_label, :gateway, :dns_primary, :dns_secondary, :vlanid
  end

  # Subnets are displayed in the form of their network network/network mask
  def to_label
    "#{network}/#{cidr}"
  end

  def title
    "#{name} (#{to_label})"
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

  def dhcp?
    !!(dhcp and dhcp.url and !dhcp.url.blank?)
  end

  def dhcp_proxy attrs = {}
    @dhcp_proxy ||= ProxyAPI::DHCP.new({:url => dhcp.url}.merge(attrs)) if dhcp?
  end

  def tftp?
    !!(tftp and tftp.url and !tftp.url.blank?)
  end

  def tftp_proxy attrs = {}
    @tftp_proxy ||= ProxyAPI::TFTP.new({:url => tftp.url}.merge(attrs)) if tftp?
  end

  # do we support DNS PTR records for this subnet
  def dns?
    !!(dns and dns.url and !dns.url.blank?)
  end

  def dns_proxy attrs = {}
    @dns_proxy ||= ProxyAPI::DNS.new({:url => dns.url}.merge(attrs)) if dns?
  end

  def unused_ip mac = nil
    return unless dhcp?
    dhcp_proxy.unused_ip(self, mac)["ip"]
  rescue => e
    logger.warn "Failed to fetch a free IP from our proxy: #{e}"
    nil
  end

  # imports subnets from a dhcp smart proxy
  def self.import proxy
    return unless proxy.features.include?(Feature.find_by_name("DHCP"))
    ProxyAPI::DHCP.new(:url => proxy.url).subnets.map do |s|
      # do not import existing networks.
      attrs = { :network => s["network"], :mask => s["netmask"] }
      next if first(:conditions => attrs)
      new(attrs.update(:dhcp => proxy))
    end.compact
  end

  private

  def validate_ranges
    errors.add(:from, "invalid IP address")            if from.present? and !from =~ Net::Validations::IP_REGEXP
    errors.add(:to, "invalid IP address")              if to.present?   and !to   =~ Net::Validations::IP_REGEXP
    errors.add(:from, "does not belong to subnet")     if from.present? and not self.contains?(f=IPAddr.new(from))
    errors.add(:to, "does not belong to subnet")       if to.present?   and not self.contains?(t=IPAddr.new(to))
    errors.add(:from, "can't be bigger than to range") if from.present? and t.present? and f > t
    if from.present? or to.present?
      errors.add(:from, "must be specified if to is defined")   if from.blank?
      errors.add(:to,   "must be specified if from is defined") if to.blank?
    end
  end

  def name_should_be_uniq_across_domains
    return if domains.empty?
    domains.each do |d|
      conds = new_record? ? ['name = ?', name] : ['subnets.name = ? AND subnets.id != ?', name, id]
      errors.add(:name, "domain #{d} already has a subnet with this name") if d.subnets.where(conds).first
    end
  end
end
