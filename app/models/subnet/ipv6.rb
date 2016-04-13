require 'socket'

class Subnet::Ipv6 < Subnet
  def self.default_sti_class
    'Subnet::Ipv6'
  end

  has_many :interfaces, :class_name => '::Nic::Base', :foreign_key => :subnet6_id
  has_many :primary_interfaces, -> { where(:primary => true) }, :class_name => 'Nic::Base', :foreign_key => :subnet6_id
  has_many :hosts, :through => :interfaces
  has_many :primary_hosts, :through => :primary_interfaces, :source => :host

  validate :validate_eui64_prefix_length, :if => Proc.new { |subnet| subnet.ipam == Subnet::IPAM_MODES[:eui64]}

  def family
    Socket::AF_INET6
  end

  def in_mask
    IPAddr::IN6MASK
  end

  def validate_ip(ip)
    Net::Validations.validate_ip6(ip)
  end

  def self.supported_ipam_modes
    [:eui64, :db, :none]
  end

  def mac_to_ip(mac)
    return nil unless network.present? && cidr.present?
    raise Foreman::Exception.new(N_("Prefix length must be /64 or less to use EUI-64")) if cidr > 64
    begin
      mac = Net::Validations.normalize_mac(mac)
    rescue ArgumentError
      raise Foreman::Exception.new(N_("'%s' is not a valid MAC address.") % mac)
    end
    mac.gsub!(/[\.\:\-]/, '')
    IPAddr.new(IPAddr.new(network, Socket::AF_INET6).to_i | ((mac.slice(0..5) + 'fffe' + mac.slice(6..11)).to_i(16) ^ 0x0200000000000000), Socket::AF_INET6).to_s
  end

  private

  def normalize_ip(address)
    Net::Validations.normalize_ip6(address)
  end

  def validate_eui64_prefix_length
    errors.add(:ipam, N_('Prefix length must be /64 or less to use EUI-64')) if cidr && cidr > 64
  end
end
