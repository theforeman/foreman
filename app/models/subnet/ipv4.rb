require 'socket'

class Subnet::Ipv4 < Subnet
  has_many :interfaces, :class_name => 'Nic::Base', :foreign_key => :subnet_id
  has_many :primary_interfaces, -> { where(:primary => true) }, :class_name => 'Nic::Base', :foreign_key => :subnet_id
  # The has_many :through associations below have to be defined after the
  # corresponding has_many associations and thus can not be defined in the parent class
  has_many :hosts, :through => :interfaces
  has_many :primary_hosts, :through => :primary_interfaces, :source => :host

  validates :mask, :format => {:with => Net::Validations::MASK_REGEXP}
  validates :mtu, :numericality => {:only_integer => true, :greater_than_or_equal_to => 68, :less_than_or_equal_to => 65536}

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
    [:dhcp, :db, :random_db, :external_ipam, :none]
  end

  def self.show_mask?
    true
  end

  def ip_sym
    :ip
  end

  def cleanup_addresses
    IP_FIELDS.each do |f|
      send("#{f}=", cleanup_ip(send(f))) if send(f).present?
    end
    self
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

  # Translate ISC dhcp subnet options names provided by dhcp proxy into foreman subnet attributes names
  def self.parse_dhcp_options(options)
    attrs = {}
    attrs[:gateway]          = options["routers"][0]             if options["routers"] && options["routers"][0]
    attrs[:dns_primary]      = options["domain_name_servers"][0] if options["domain_name_servers"] && options["domain_name_servers"][0]
    attrs[:dns_secondary]    = options["domain_name_servers"][1] if options["domain_name_servers"] && options["domain_name_servers"][1]
    attrs[:from], attrs[:to] = options["range"]                  if options["range"] && options["range"][0] && options["range"][1]

    attrs
  end

  private_class_method :parse_dhcp_options

  private

  def cleanup_ip(address)
    address.gsub(/\.\.+/, ".").
            gsub(/2555+/, "255")
  end

  def normalize_ip(address)
    Net::Validations.normalize_ip(address)
  end
end
