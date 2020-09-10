require 'socket'

class Subnet::Ipv6 < Subnet
  has_many :interfaces, :class_name => '::Nic::Base', :foreign_key => :subnet6_id
  has_many :primary_interfaces, -> { where(:primary => true) }, :class_name => 'Nic::Base', :foreign_key => :subnet6_id
  # The has_many :through associations below have to be defined after the
  # corresponding has_many associations and thus can not be defined in the parent class
  has_many :hosts, :through => :interfaces
  has_many :primary_hosts, :through => :primary_interfaces, :source => :host

  validate :validate_eui64_prefix_length, :if => proc { |subnet| subnet.ipam == IPAM::MODES[:eui64] }
  validates :mtu, :numericality => {:only_integer => true, :greater_than_or_equal_to => 1280, :less_than_or_equal_to => 4294967295}

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
    [:eui64, :db, :external_ipam, :none]
  end

  def self.show_mask?
    false
  end

  def ip_sym
    :ip6
  end

  private

  def normalize_ip(address)
    Net::Validations.normalize_ip6(address)
  end

  def validate_eui64_prefix_length
    errors.add(:ipam, N_('Prefix length must be /64 or less to use EUI-64')) if cidr && cidr > 64
  end
end
