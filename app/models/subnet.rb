require 'ipaddr'

class Subnet < ActiveRecord::Base
  IP_FIELDS = [:network, :mask, :gateway, :dns_primary, :dns_secondary, :from, :to]
  REQUIRED_IP_FIELDS = [:network, :mask]
  SUBNET_TYPES = {:'Subnet::Ipv4' => N_('IPv4')}
  BOOT_MODES = {:static => N_('Static'), :dhcp => N_('DHCP')}
  IPAM_MODES = {:dhcp => N_('DHCP'), :db => N_('Internal DB'), :none => N_('None')}

  include Authorizable
  include Foreman::STI
  extend FriendlyId
  friendly_id :name
  include Taxonomix
  include Parameterizable::ByIdName
  include EncOutput
  attr_accessible :name, :type, :network, :mask, :gateway, :dns_primary, :dns_secondary, :ipam, :from,
    :to, :vlanid, :boot_mode, :dhcp_id, :dhcp, :tftp_id, :tftp, :dns_id, :dns, :domain_ids, :domain_names,
    :subnet_parameters_attributes, :cidr

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
  validates_associated    :subnet_domains
  validates :boot_mode, :inclusion => BOOT_MODES.values
  validates :ipam, :inclusion => {:in => Proc.new { |subnet| subnet.class.supported_ipam_modes.map {|m| Subnet::IPAM_MODES[m]} }, :message => N_('not supported by this protocol')}
  validates :type, :inclusion => {:in => Proc.new { Subnet::SUBNET_TYPES.keys.map(&:to_s) }, :message => N_("must be one of [ %s ]" % Subnet::SUBNET_TYPES.keys.map(&:to_s).join(', ')) }
  validates :name,    :length => {:maximum => 255}, :uniqueness => true

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

  class Jail < ::Safemode::Jail
    allow :name, :network, :mask, :cidr, :title, :to_label, :gateway, :dns_primary, :dns_secondary,
          :vlanid, :boot_mode, :dhcp?, :nil?, :has_vlanid?, :dhcp_boot_mode?
  end

  def self.modes_with_translations(modes)
    modes.map { |_, mode_name| [_(mode_name), mode_name] }
  end

  def self.boot_modes_with_translations
    modes_with_translations(BOOT_MODES)
  end

  def self.ipam_modes_with_translations
    modes_with_translations(IPAM_MODES)
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
  def <=>(other)
    if self.vlanid.present? && other.vlanid.present?
      self.vlanid <=> other.vlanid
    else
      return -1
    end
  end

  # Given an IP returns the subnet that contains that IP
  # [+ip+] : IPv4 address
  # Returns : Subnet object or nil if not found
  def self.subnet_for(ip)
    ip = IPAddr.new(ip)
    Subnet.all.detect {|s| s.family == ip.family && s.contains?(ip)}
  end

  # Indicates whether the IP is within this subnet
  # [+ip+] String: IPv4 address
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

  def supports_ipam_mode?(mode)
    self.class.supported_ipam_modes.include?(mode)
  end

  def dhcp?
    !!(dhcp and dhcp.url and !dhcp.url.blank?)
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
    self.ipam != IPAM_MODES[:none]
  end

  def dhcp_boot_mode?
    self.boot_mode == Subnet::BOOT_MODES[:dhcp]
  end

  def unused_ip(mac = nil, excluded_ips = [])
    unless ipam?
      logger.debug "Not suggesting IP Address for #{self} as IPAM is disabled"
      return
    end

    if self.ipam == IPAM_MODES[:dhcp] && dhcp? && supports_ipam_mode?(:dhcp)
      # we have DHCP proxy so asking it for free IP
      logger.debug "Asking #{dhcp.url} for free IP"
      ip = dhcp_proxy.unused_ip(self, mac)["ip"]
      logger.debug("Found #{ip}")
      return(ip)
    elsif self.ipam == IPAM_MODES[:db] && supports_ipam_mode?(:db)
      # we have no DHCP proxy configured so Foreman becomes `DHCP` and manages reservations internally
      logger.debug "Trying to find free IP for subnet in internal DB"
      subnet_range = IPAddr.new("#{network}/#{mask}", family).to_range
      from = self.from.present? ? IPAddr.new(self.from) : subnet_range.first(2).last
      to = self.to.present? ? IPAddr.new(self.to) : IPAddr.new(subnet_range.last.to_i - 2, family)
      (from..to).each do |address|
        ip = address.to_s
        if !self.known_ips.include?(ip) && !excluded_ips.include?(ip)
          logger.debug("Found #{ip}")
          return(ip)
        end
      end
      logger.debug("Not suggesting IP Address for #{self} as no free IP found in our DB")
      return
    end
  rescue => e
    logger.warn "Failed to fetch a free IP from our proxy: #{e}"
    nil
  end

  def known_ips
    ips = self.interfaces.map(&:ip) + self.hosts.includes(:interfaces).map(&:ip)
    ips += [self.gateway, self.dns_primary, self.dns_secondary].select(&:present?)
    self.clear_association_cache
    ips.compact.uniq
  end

  # imports subnets from a dhcp smart proxy
  def self.import(proxy)
    return unless proxy.has_feature?('DHCP')
    ProxyAPI::DHCP.new(:url => proxy.url).subnets.map do |s|
      # do not import existing networks.
      attrs = { :network => s["network"], :mask => s["netmask"] }

      next if exists?(attrs)
      attrs.merge!(parse_dhcp_options(s['options'])) if s['options'].present?
      new(attrs.update(:dhcp => proxy))
    end.compact
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

  # Translate ISC dhcp subnet options names provided by dhcp proxy into foreman subnet attributes names
  def self.parse_dhcp_options(options)
    attrs = {}
    attrs[:gateway]          = options["routers"][0]             if options["routers"] && options["routers"][0]
    attrs[:dns_primary]      = options["domain_name_servers"][0] if options["domain_name_servers"] && options["domain_name_servers"][0]
    attrs[:dns_secondary]    = options["domain_name_servers"][1] if options["domain_name_servers"] && options["domain_name_servers"][1]
    attrs[:from], attrs[:to] = options["range"]                  if options["range"] && options["range"][0] && options["range"][1]

    attrs
  end

  def validate_ranges
    if from.present? or to.present?
      errors.add(:from, _("must be specified if to is defined"))   if from.blank?
      errors.add(:to,   _("must be specified if from is defined")) if to.blank?
    end
    return if errors.keys.include?(:from) || errors.keys.include?(:to)
    errors.add(:from, _("does not belong to subnet"))     if from.present? and not self.contains?(f=IPAddr.new(from))
    errors.add(:to, _("does not belong to subnet"))       if to.present?   and not self.contains?(t=IPAddr.new(to))
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

  private

  def invalid_address_error
    # IPAddr::InvalidAddressError is undefined for ruby 1.9
    return IPAddr::InvalidAddressError if IPAddr.const_defined?('InvalidAddressError')
    ArgumentError
  end

  def enc_attributes
    @enc_attributes ||= %w(name type network mask cidr gateway dns_primary dns_secondary from to boot_mode ipam vlanid)
  end
end
