require 'ipaddr'

class Subnet < ActiveRecord::Base
  IP_FIELDS = [:network, :mask, :gateway, :dns_primary, :dns_secondary, :from, :to]
  REQUIRED_IP_FIELDS = [:network, :mask]
  SUBNET_TYPES = {:'Subnet::Ipv4' => N_('IPv4'), :'Subnet::Ipv6' => N_('IPv6')}
  BOOT_MODES = {:static => N_('Static'), :dhcp => N_('DHCP')}

  include Authorizable
  include Foreman::STI
  extend FriendlyId
  friendly_id :name
  include Taxonomix
  include Parameterizable::ByIdName
  include Exportable

  attr_accessible :name, :type, :network, :mask, :gateway, :dns_primary, :dns_secondary, :ipam, :from,
    :to, :vlanid, :boot_mode, :dhcp_id, :dhcp, :tftp_id, :tftp, :dns_id, :dns, :domain_ids, :domain_names,
    :subnet_parameters_attributes, :cidr

  attr_exportable :name, :network, :mask, :gateway, :dns_primary, :dns_secondary, :from, :to, :boot_mode,
    :ipam, :vlanid, :type

  # This casts Subnet to Subnet::Ipv4 if no type is set
  def self.new(*attributes, &block)
    return Subnet::Ipv4.new_without_cast(*attributes, &block) if self == Subnet
    super
  end

  # This sets the rails model name of all child classes to the
  # model name of the parent class, i.e. Subnet.
  # This is necessary for all STI classes to share the same
  # route_key, param_key, ...
  def self.inherited(child)
    child.instance_eval do
      # rubocop:disable Rails/Delegate
      def model_name
        superclass.model_name
      end
      # rubocop:enable Rails/Delegate
    end
    super
  end

  audited :allow_mass_assignment => true

  validates_lengths_from_database :except => [:gateway]
  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups, :interfaces, :domains)
  has_many :hostgroups
  belongs_to :dhcp, :class_name => "SmartProxy"
  belongs_to :tftp, :class_name => "SmartProxy"
  belongs_to :dns,  :class_name => "SmartProxy"
  has_many :subnet_domains, :dependent => :destroy, :inverse_of => :subnet
  has_many :domains, :through => :subnet_domains
  has_many :subnet_parameters, :dependent => :destroy, :foreign_key => :reference_id, :inverse_of => :subnet
  has_many :parameters, :dependent => :destroy, :foreign_key => :reference_id, :class_name => "SubnetParameter"
  accepts_nested_attributes_for :subnet_parameters, :allow_destroy => true
  validates :network, :mask, :name, :cidr, :presence => true
  validates_associated :subnet_domains
  validates :boot_mode, :inclusion => BOOT_MODES.values
  validates :ipam, :inclusion => {:in => Proc.new { |subnet| subnet.supported_ipam_modes.map {|m| IPAM::MODES[m]} }, :message => N_('not supported by this protocol')}
  validates :type, :inclusion => {:in => Proc.new { Subnet::SUBNET_TYPES.keys.map(&:to_s) }, :message => N_("must be one of [ %s ]" % Subnet::SUBNET_TYPES.keys.map(&:to_s).join(', ')) }
  validates :name, :length => {:maximum => 255}, :uniqueness => true

  validates :dns, :proxy_features => { :feature => "DNS", :message => N_('does not have the DNS feature') }
  validates :tftp, :proxy_features => { :feature => "TFTP", :message => N_('does not have the TFTP feature') }
  validates :dhcp, :proxy_features => { :feature => "DHCP", :message => N_('does not have the DHCP feature') }
  validates :network, :uniqueness => true

  before_validation :normalize_addresses
  validate :ensure_ip_addrs_valid

  validate :validate_ranges
  validate :check_if_type_changed, :on => :update

  default_scope lambda {
    with_taxonomy_scope do
      order('vlanid')
    end
  }

  scoped_search :on => [:name, :network, :mask, :gateway, :dns_primary, :dns_secondary,
                        :vlanid, :ipam, :boot_mode, :type], :complete_value => true

  scoped_search :in => :domains, :on => :name, :rename => :domain, :complete_value => true
  scoped_search :in => :subnet_parameters, :on => :value, :on_key=> :name, :complete_value => true, :only_explicit => true, :rename => :params

  delegate :supports_ipam_mode?, :supported_ipam_modes, to: 'self.class'

  class Jail < ::Safemode::Jail
    allow :name, :network, :mask, :cidr, :title, :to_label, :gateway, :dns_primary, :dns_secondary,
          :vlanid, :boot_mode, :dhcp?, :nil?, :has_vlanid?, :dhcp_boot_mode?
  end

  # Subnets are displayed in the form of their network network/network mask
  def network_address
    "#{network}/#{cidr}"
  end

  def to_label
    "#{name} (#{network_address})"
  end

  def to_s
    name
  end

  # Subnets are sorted on their priority value
  # [+other+] : Subnet object with which to compare ourself
  # +returns+ : Subnet object with higher precedence
  def <=>(other)
    if self.vlanid.present? && other.vlanid.present?
      self.vlanid <=> other.vlanid
    else
      return -1
    end
  end

  # Indicates whether the IP is within this subnet
  # [+ip+] String: IPv4 or IPv6 address
  # Returns Boolean: True if if ip is in this subnet
  def contains?(ip)
    ipaddr.include? IPAddr.new(ip, family)
  end

  def ipaddr
    IPAddr.new("#{network}/#{mask}", family)
  end

  def cidr
    return if mask.nil?
    IPAddr.new(mask).to_i.to_s(2).count("1")
  rescue invalid_address_error
    nil
  end

  def cidr=(cidr)
    return if cidr.nil?
    self[:mask] = IPAddr.new(in_mask, family).mask(cidr).to_s
  rescue invalid_address_error
    nil
  end

  def dhcp?
    supports_ipam_mode?(:dhcp) && dhcp && dhcp.url.present?
  end

  def dhcp_proxy(attrs = {})
    @dhcp_proxy ||= ProxyAPI::DHCP.new({:url => dhcp.url}.merge(attrs)) if dhcp?
  end

  def tftp?
    !!(tftp and tftp.url and !tftp.url.blank?)
  end

  def tftp_proxy(attrs = {})
    @tftp_proxy ||= ProxyAPI::TFTP.new({:url => tftp.url}.merge(attrs)) if tftp?
  end

  # do we support DNS PTR records for this subnet
  def dns?
    !!(dns and dns.url and !dns.url.blank?)
  end

  def dns_proxy(attrs = {})
    @dns_proxy ||= ProxyAPI::DNS.new({:url => dns.url}.merge(attrs)) if dns?
  end

  def ipam?
    self.ipam != IPAM::MODES[:none]
  end

  def dhcp_boot_mode?
    self.boot_mode == Subnet::BOOT_MODES[:dhcp]
  end

  def unused_ip(mac = nil, excluded_ips = [])
    unless ipam?
      logger.debug "Not suggesting IP Address for #{self} as IPAM is disabled"
      return
    end

    unless supported_ipam_modes.map {|m| IPAM::MODES[m]}.include?(self.ipam)
      raise ::Foreman::Exception.new(N_("Unsupported IPAM mode for %s") % self.class)
    end

    opts = {:subnet => self, :mac => mac, :excluded_ips => excluded_ips}
    ipam = IPAM.new(self.ipam, opts)
    ipam.suggest_ip
  rescue => e
    logger.warn "Failed to fetch a free IP from our proxy: #{e}"
    nil
  end

  def known_ips
    ips = self.interfaces.map(&ip_sym) + self.hosts.includes(:interfaces).map(&ip_sym)
    ips += [self.gateway, self.dns_primary, self.dns_secondary].select(&:present?)
    self.clear_association_cache
    ips.compact.uniq
  end

  def proxies
    [dhcp, tftp, dns].compact
  end

  def has_vlanid?
    self.vlanid.present?
  end

  # overwrite method in taxonomix, since subnet is not direct association of host anymore
  def used_taxonomy_ids(type)
    return [] if new_record?
    Host::Base.joins(:primary_interface).where(:nics => {:subnet_id => id}).uniq.pluck(type).compact
  end

  def as_json(options = {})
    super({:methods => [:to_label, :type]}.merge(options))
  end

  private

  def validate_ranges
    if from.present? or to.present?
      errors.add(:from, _("must be specified if to is defined"))   if from.blank?
      errors.add(:to,   _("must be specified if from is defined")) if to.blank?
    end
    return if errors.keys.include?(:from) || errors.keys.include?(:to)
    errors.add(:from, _("does not belong to subnet"))     if from.present? and !self.contains?(f=IPAddr.new(from))
    errors.add(:to, _("does not belong to subnet"))       if to.present?   and !self.contains?(t=IPAddr.new(to))
    errors.add(:from, _("can't be bigger than to range")) if from.present? and t.present? and f > t
  end

  def check_if_type_changed
    if self.type_changed?
      errors.add(:type, _("can't be updated after subnet is saved"))
    end
  end

  def normalize_addresses
    IP_FIELDS.each do |f|
      val = send(f)
      send("#{f}=", normalize_ip(val)) if val.present?
    end
    self
  end

  def ensure_ip_addrs_valid
    IP_FIELDS.each do |f|
      errors.add(f, _("is invalid")) if (send(f).present? || REQUIRED_IP_FIELDS.include?(f)) && !validate_ip(send(f)) && !errors.keys.include?(f)
    end
  end

  class << self
    def modes_with_translations(modes)
      modes.map { |_, mode_name| [_(mode_name), mode_name] }
    end

    def boot_modes_with_translations
      modes_with_translations(BOOT_MODES)
    end

    def ipam_modes_with_translations
      modes_with_translations(IPAM::MODES)
    end

    def supports_ipam_mode?(mode)
      supported_ipam_modes.include?(mode)
    end

    # Given an IP returns the subnet that contains that IP
    # [+ip+] : IPv4 or IPv6 address
    # Returns : Subnet object or nil if not found
    def subnet_for(ip)
      ip = IPAddr.new(ip)
      Subnet.all.detect {|s| s.family == ip.family && s.contains?(ip)}
    end
  end

  private

  def invalid_address_error
    # IPAddr::InvalidAddressError is undefined for ruby 1.9
    return IPAddr::InvalidAddressError if IPAddr.const_defined?('InvalidAddressError')
    ArgumentError
  end
end
