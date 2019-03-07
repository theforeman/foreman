require 'ipaddr'

class Subnet < ApplicationRecord
  audited
  IP_FIELDS = [:network, :mask, :gateway, :dns_primary, :dns_secondary, :from, :to]
  REQUIRED_IP_FIELDS = [:network, :mask]
  SUBNET_TYPES = {:'Subnet::Ipv4' => N_('IPv4'), :'Subnet::Ipv6' => N_('IPv6')}
  BOOT_MODES = {:static => N_('Static'), :dhcp => N_('DHCP')}

  include Authorizable
  prepend Foreman::STI
  extend FriendlyId
  friendly_id :name
  include Taxonomix
  include Parameterizable::ByIdName
  include Exportable
  include BelongsToProxies

  attr_exportable :name, :network, :mask, :gateway, :dns_primary, :dns_secondary, :from, :to, :boot_mode,
    :ipam, :vlanid, :mtu, :network_type, :description

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

  validates_lengths_from_database :except => [:gateway]
  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups, :interfaces, :domains)

  belongs_to_proxy :dhcp,
    :feature => 'DHCP',
    :label => N_('DHCP Proxy'),
    :description => N_('DHCP Proxy to use within this subnet'),
    :api_description => N_('DHCP Proxy ID to use within this subnet'),
    :if => ->(subnet) { subnet.supports_ipam_mode?(:dhcp) }

  belongs_to_proxy :tftp,
    :feature => N_('TFTP'),
    :label => N_('TFTP Proxy'),
    :api_description => N_('TFTP Proxy ID to use within this subnet'),
    :description => N_('TFTP Proxy to use within this subnet')

  belongs_to_proxy :httpboot,
    :feature => N_('HTTPBoot'),
    :label => N_('HTTPBoot Proxy'),
    :api_description => N_('HTTPBoot Proxy ID to use within this subnet'),
    :description => N_('HTTPBoot Proxy to use within this subnet')

  belongs_to_proxy :dns,
    :feature => N_('DNS'),
    :label => N_('Reverse DNS Proxy'),
    :api_description => N_('DNS Proxy ID to use within this subnet'),
    :description => N_('DNS Proxy to use within this subnet for managing PTR records, note that A and AAAA records are managed via Domain DNS proxy')

  belongs_to_proxy :template,
    :feature => N_('Templates'),
    :label => N_('Template Proxy'),
    :api_description => N_('Template HTTP(S) Proxy ID to use within this subnet'),
    :description => N_('Template HTTP(S) Proxy to use within this subnet to allow access templating endpoint from isolated networks')

  has_many :hostgroups
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
  validates :vlanid, numericality: { :only_integer => true, :greater_than_or_equal_to => 0, :less_than => 4096}, :allow_blank => true
  validates :mtu, :presence => true

  before_validation :normalize_addresses
  validate :ensure_ip_addrs_valid

  validate :validate_ranges
  validate :check_if_type_changed, :on => :update

  default_scope lambda {
    with_taxonomy_scope do
      order(:vlanid)
    end
  }

  scoped_search :on => [:name, :network, :mask, :gateway, :dns_primary, :dns_secondary,
                        :vlanid, :mtu, :ipam, :boot_mode, :type], :complete_value => true

  scoped_search :relation => :domains, :on => :name, :rename => :domain, :complete_value => true
  scoped_search :relation => :subnet_parameters, :on => :value, :on_key => :name, :complete_value => true, :only_explicit => true, :rename => :params

  delegate :supports_ipam_mode?, :supported_ipam_modes, :show_mask?, to: 'self.class'

  class Jail < ::Safemode::Jail
    allow :name, :network, :mask, :cidr, :title, :to_label, :gateway, :dns_primary, :dns_secondary, :dns_servers,
          :vlanid, :mtu, :boot_mode, :dhcp?, :nil?, :has_vlanid?, :dhcp_boot_mode?, :description, :present?
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

  def network_type
    SUBNET_TYPES[type.to_sym]
  end

  def network_type=(value)
    self[:type] = SUBNET_TYPES.key(value)
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
    !!(tftp && tftp.url && tftp.url.present?)
  end

  def tftp_proxy(attrs = {})
    @tftp_proxy ||= ProxyAPI::TFTP.new({:url => tftp.url}.merge(attrs)) if tftp?
  end

  def httpboot?
    !!(httpboot && httpboot.url && httpboot.url.present?)
  end

  def httpboot_proxy(attrs = {})
    @httpboot_proxy ||= ProxyAPI::TFTP.new({:url => httpboot.url}.merge(attrs)) if httpboot?
  end

  # do we support DNS PTR records for this subnet
  def dns?
    !!(dns && dns.url && dns.url.present?)
  end

  def dns_proxy(attrs = {})
    @dns_proxy ||= ProxyAPI::DNS.new({:url => dns.url}.merge(attrs)) if dns?
  end

  def template?
    !!(template && template.url)
  end

  def template_proxy(attrs = {})
    @template_proxy ||= ProxyAPI::Template.new({:url => template.url}.merge(attrs)) if template?
  end

  def ipam?
    self.ipam != IPAM::MODES[:none]
  end

  def ipam_needs_range?
    ipam? && self.ipam != IPAM::MODES[:eui64]
  end

  def dhcp_boot_mode?
    self.boot_mode == Subnet::BOOT_MODES[:dhcp]
  end

  def unused_ip(mac = nil, excluded_ips = [])
    unless supported_ipam_modes.map {|m| IPAM::MODES[m]}.include?(self.ipam)
      raise ::Foreman::Exception.new(N_("Unsupported IPAM mode for %s"), self.class.name)
    end

    opts = {:subnet => self, :mac => mac, :excluded_ips => excluded_ips}
    IPAM.new(self.ipam, opts)
  end

  def known_ips
    self.interfaces.reload
    ips = self.interfaces.map(&ip_sym) + self.hosts.includes(:interfaces).map(&ip_sym)
    ips += [self.gateway, self.dns_primary, self.dns_secondary].select(&:present?)
    ips.compact.uniq
  end

  def proxies
    [dhcp, tftp, dns, httpboot].compact
  end

  def has_vlanid?
    self.vlanid.present?
  end

  # overwrite method in taxonomix, since subnet is not direct association of host anymore
  def used_taxonomy_ids(type)
    return [] if new_record?
    Host::Base.joins(:primary_interface).where(:nics => {:subnet_id => id}).distinct.pluck(type).compact
  end

  def as_json(options = {})
    super({:methods => [:to_label, :type]}.merge(options))
  end

  def dns_servers
    [dns_primary, dns_secondary].select(&:present?)
  end

  private

  def validate_ranges
    if from.present? || to.present?
      errors.add(:from, _("must be specified if to is defined"))   if from.blank?
      errors.add(:to,   _("must be specified if from is defined")) if to.blank?
    end
    return if errors.key?(:from) || errors.key?(:to)
    errors.add(:from, _("does not belong to subnet"))     if from.present? && !self.contains?(f = IPAddr.new(from))
    errors.add(:to, _("does not belong to subnet"))       if to.present?   && !self.contains?(t = IPAddr.new(to))
    errors.add(:from, _("can't be bigger than to range")) if from.present? && t.present? && f > t
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
      errors.add(f, _("is invalid")) if (send(f).present? || REQUIRED_IP_FIELDS.include?(f)) && !validate_ip(send(f)) && !errors.key?(f)
    end
  end

  class << self
    def boot_modes_with_translations
      BOOT_MODES.map { |_, mode_name| [_(mode_name), mode_name] }
    end

    def supports_ipam_mode?(mode)
      supported_ipam_modes.include?(mode)
    end

    def supported_ipam_modes_with_translations
      supported_ipam_modes.map {|mode| [_(IPAM::MODES[mode]), IPAM::MODES[mode]]}
    end

    # Given an IP returns the subnet that contains that IP preferring highest CIDR prefix
    # [+ip+] : IPv4 or IPv6 address
    # Returns : Subnet object or nil if not found
    def subnet_for(ip)
      return unless ip.present?
      ip = IPAddr.new(ip)
      Subnet.unscoped.all.select {|s| s.family == ip.family && s.contains?(ip)}.max_by(&:cidr)
    end

    # This casts Subnet to Subnet::Ipv4 if no type is set
    def new(*attributes, &block)
      type = attributes.first.with_indifferent_access.delete(:type) if attributes.first.is_a?(Hash)
      return Subnet::Ipv4.new(*attributes, &block) if self == Subnet && type.nil?
      super
    end

    # allows to create a specific subnet class based on the network_type.
    # network_type is more user friendly than the class names
    def new_network_type(args)
      network_type = args.delete(:network_type) || 'IPv4'
      SUBNET_TYPES.each do |network_type_class, network_type_name|
        return network_type_class.to_s.constantize.new(args) if network_type_name.downcase == network_type.downcase
      end
      raise ::Foreman::Exception.new N_("unknown network_type")
    end
  end

  def invalid_address_error
    # IPAddr::InvalidAddressError is undefined for ruby 1.9
    return IPAddr::InvalidAddressError if IPAddr.const_defined?('InvalidAddressError')
    ArgumentError
  end
end
