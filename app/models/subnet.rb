require 'ipaddr'
class Subnet < ActiveRecord::Base
  include Authorizable
  include Taxonomix
  audited :allow_mass_assignment => true

  before_destroy EnsureNotUsedBy.new(:hosts, :interfaces )
  has_many_hosts
  has_many :hostgroups
  belongs_to :dhcp, :class_name => "SmartProxy"
  belongs_to :tftp, :class_name => "SmartProxy"
  belongs_to :dns,  :class_name => "SmartProxy"
  has_many :subnet_domains, :dependent => :destroy
  has_many :domains, :through => :subnet_domains
  has_many :interfaces, :class_name => 'Nic::Base'
  validates :network, :mask, :name, :presence => true
  validates_associated    :subnet_domains
  validates :network, :uniqueness => true,
                      :format => {:with => Net::Validations::IP_REGEXP},
                      :length => {:maximum => 15, :message => N_("must be at most 15 characters")}
  validates :gateway, :dns_primary, :dns_secondary,
                      :allow_blank => true,
                      :allow_nil => true,
                      :format => {:with => Net::Validations::IP_REGEXP},
                      :length => { :maximum => 15, :message => N_("must be at most 15 characters") }
  validates :mask,    :format => {:with => Net::Validations::IP_REGEXP},
                      :length => {:maximum => 15, :message => N_("must be at most 15 characters")}

  validate :ensure_ip_addr_new
  before_validation :cleanup_addresses
  validate :name_should_be_uniq_across_domains

  validate :validate_ranges

  default_scope lambda {
    with_taxonomy_scope do
      order('vlanid')
    end
  }

  scoped_search :on => [:name, :network, :mask, :gateway, :dns_primary, :dns_secondary, :vlanid], :complete_value => true
  scoped_search :in => :domains, :on => :name, :rename => :domain, :complete_value => true

  class Jail < ::Safemode::Jail
    allow :name, :network, :mask, :cidr, :title, :to_label, :gateway, :dns_primary, :dns_secondary, :vlanid
  end

  # Subnets are displayed in the form of their network network/network mask
  def network_address
    "#{network}/#{cidr}"
  end

  def to_label
    "#{name} (#{network_address})"
  end

  # Subnets are sorted on their priority value
  # [+other+] : Subnet object with which to compare ourself
  # +returns+ : Subnet object with higher precedence
  def <=> (other)
    if self.vlanid.present? && other.vlanid.present?
      self.vlanid <=> other.vlanid
    else
      return -1
    end
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
    errors.add(:from, _("invalid IP address"))            if from.present? and !from =~ Net::Validations::IP_REGEXP
    errors.add(:to, _("invalid IP address"))              if to.present?   and !to   =~ Net::Validations::IP_REGEXP
    errors.add(:from, _("does not belong to subnet"))     if from.present? and not self.contains?(f=IPAddr.new(from))
    errors.add(:to, _("does not belong to subnet"))       if to.present?   and not self.contains?(t=IPAddr.new(to))
    errors.add(:from, _("can't be bigger than to range")) if from.present? and t.present? and f > t
    if from.present? or to.present?
      errors.add(:from, _("must be specified if to is defined"))   if from.blank?
      errors.add(:to,   _("must be specified if from is defined")) if to.blank?
    end
  end

  def name_should_be_uniq_across_domains
    return if domains.empty?
    domains.each do |d|
      conds = new_record? ? ['name = ?', name] : ['subnets.name = ? AND subnets.id != ?', name, id]
      errors.add(:name, _("domain %s already has a subnet with this name") % d) if d.subnets.where(conds).first
    end
  end

  def cleanup_addresses
    self.network = cleanup_ip(network) if network.present?
    self.mask = cleanup_ip(mask) if mask.present?
    self.gateway = cleanup_ip(gateway) if gateway.present?
    self.dns_primary = cleanup_ip(dns_primary) if dns_primary.present?
    self.dns_secondary = cleanup_ip(dns_secondary) if dns_secondary.present?
    self
  end

  def cleanup_ip(address)
    address.gsub!(/\.\.+/, ".")
    address.gsub!(/2555+/, "255")
    address
  end

  def ensure_ip_addr_new
    errors.add(:network, _("is invalid")) if network.present? && (IPAddr.new(network) rescue nil).nil? && !errors.keys.include?(:network)
    errors.add(:mask, _("is invalid")) if mask.present? && (IPAddr.new(mask) rescue nil).nil? && !errors.keys.include?(:mask)
    errors.add(:gateway, _("is invalid")) if gateway.present? && (IPAddr.new(gateway) rescue nil).nil? && !errors.keys.include?(:gateway)
    errors.add(:dns_primary, _("is invalid")) if dns_primary.present? && (IPAddr.new(dns_primary) rescue nil).nil? && !errors.keys.include?(:dns_primary)
    errors.add(:dns_secondary, _("is invalid")) if dns_secondary.present? && (IPAddr.new(dns_secondary) rescue nil).nil? && !errors.keys.include?(:dns_secondary)
  end

end
