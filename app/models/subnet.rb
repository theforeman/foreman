require 'ipaddr'
class Subnet < ActiveRecord::Base
  def self.default_sti_class
    'Subnet::Ipv4'
  end

  IP_FIELDS = [:network, :mask, :gateway, :dns_primary, :dns_secondary, :from, :to]
  REQUIRED_IP_FIELDS = [:network, :mask]
  SUBNET_TYPES = {:'Subnet::Ipv4' => N_('IPv4'), :'Subnet::Ipv6' => N_('IPv6')}
  BOOT_MODES = {:static => N_('Static'), :dhcp => N_('DHCP')}
  IPAM_MODES = {:dhcp => N_('DHCP'), :db => N_('Internal DB'), :eui64 => N_('EUI-64'), :none => N_('None')}

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

  before_validation :cleanup_addresses
  before_validation :normalize_addresses
  validate :ensure_ip_addrs_valid

  validate :validate_ranges
  validate :check_if_type_changed, :on => :update

  default_scope lambda {
    with_taxonomy_scope do
      order('vlanid')
    end
  }

  scope :completer_scope, lambda { |opt|
    return where(nil) if opts[:controller] != 'hosts'
    type = nil
    type = 'Subnet::Ipv4' if opts[:completion_field] == 'subnet'
    type = 'Subnet::Ipv6' if opts[:completion_field] == 'subnet6'
    return select(:type).where('type = ?', type) unless type.nil?
    where(nil)
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

  def self.supported_ipam_modes_for_type(type)
    type.to_s.constantize.supported_ipam_modes
  end

  def self.ipam_modes_for_type(type = nil)
    type = SUBNET_TYPES.keys.first if type.nil?
    IPAM_MODES.select { |klass, _| supported_ipam_modes_for_type(type).include?(klass) }
  end

  def self.ipam_modes_with_translations_for_type(type = nil)
    modes_with_translations(ipam_modes_for_type(type))
  end

  def self.types_with_form_data
    SUBNET_TYPES.map do |klass, type_name|
      [
        _(type_name),
        klass.to_s,
        {
          'data-supported_ipam_modes' => supported_ipam_modes_for_type(klass).map {|mode| IPAM_MODES[mode]}.to_json,
          'data-supports_dhcp' => klass.to_s.constantize.supports_dhcp?,
        }
      ]
    end
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
  # [+ip+] : IPv4 or IPv6 address
  # Returns : Subnet object or nil if not found
  def self.subnet_for(ip)
    ip = IPAddr.new(ip)
    Subnet.all.each {|s| return s if s.family == ip.family && s.contains?(ip)}
    nil
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
  rescue ArgumentError
    nil
  end

  def cidr=(cidr)
    return if cidr.nil?
    self[:mask] = IPAddr.new(in_mask, family).mask(cidr).to_s
  rescue ArgumentError
    nil
  end

  def self.supported_ipam_modes
    Subnet::Ipv4.supported_ipam_modes
  end

  def self.supports_dhcp?
    supported_ipam_modes.include?(:dhcp)
  end

  def supports_ipam_mode?(mode)
    self.class.supported_ipam_modes.include?(mode)
  end

  def dhcp?
    !!(dhcp and dhcp.url and !dhcp.url.blank? and self.class.supports_dhcp?)
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

  def ipam_needs_range?
    self.ipam != IPAM_MODES[:none] && self.ipam != Subnet::IPAM_MODES[:eui64]
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
    elsif self.ipam == IPAM_MODES[:eui64] && supports_ipam_mode?(:eui64)
      logger.debug("Suggesting ip for #{self} based on mac '#{mac}' (EUI-64).")
      return unless mac.present?
      ip = mac_to_ip(mac)
      logger.debug("Found #{ip}")
      return ip
    end
  rescue => e
    logger.warn "Failed to fetch a free IP from our proxy: #{e}"
    nil
  end

  def known_ips
    ips = self.interfaces.map(&:ip) + self.hosts.includes(:interfaces).map(&:ip)
    ips += self.interfaces.map(&:ip6) + self.hosts.includes(:interfaces).map(&:ip6)
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

  def cleanup_addresses
    IP_FIELDS.each do |f|
      send("#{f}=", cleanup_ip(send(f))) if send(f).present?
    end
    self
  end

  def cleanup_ip(address)
    address.gsub!(/\.\.+/, ".")
    address
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

  def enc_attributes
    @enc_attributes ||= %w(name type network mask cidr gateway dns_primary dns_secondary from to boot_mode ipam vlanid)
  end
end
