# Represents a Host's network interface
# This class is the both parent
module Nic
  class Base < ApplicationRecord
    audited associated_with: :host
    prepend Foreman::STI
    include Encryptable
    encrypts :password

    self.table_name = 'nics'

    validates_lengths_from_database

    before_validation :normalize_mac
    after_validation :set_validated
    before_destroy :not_required_interface

    validate :mac_uniqueness,
      :if => proc { |nic| nic.managed? && nic.host && nic.host.managed? && !nic.host.compute? && !nic.virtual? && nic.mac.present? }
    validates :mac, :presence => true,
              :if => proc { |nic| nic.managed? && nic.host_managed? && !nic.host.compute? && !nic.host.compute_provides?(:mac) && !nic.virtual? && (nic.provision? || nic.subnet.present? || nic.subnet6.present?) }
    validate :validate_mac_is_unicast,
      :if => proc { |nic| nic.managed? && !nic.virtual? }
    validates :mac, :mac_address => true, :allow_blank => true

    validates :host, :presence => true, :if => proc { |nic| nic.require_host? }

    validates :identifier, :uniqueness => { :scope => :host_id },
      :if => ->(nic) { nic.identifier.present? && nic.host && nic.identifier_was.blank? }

    validate :exclusive_primary_interface
    validate :exclusive_provision_interface
    validates :domain, :presence => true, :if => proc { |nic| nic.host_managed? && nic.primary? }
    validate :valid_domain, :if => proc { |nic| nic.host_managed? && nic.primary? }
    validates :ip, :presence => true, :if => proc { |nic| nic.host_managed? && nic.require_ip4_validation? }
    validates :ip6, :presence => true, :if => proc { |nic| nic.host_managed? && nic.require_ip6_validation? }

    validate :validate_subnet_types
    validates_with SubnetsConsistencyValidator
    validate :validate_updating_types

    # Validate that subnet's taxonomies are defined for nic's host
    validates :subnet, :belongs_to_host_taxonomy => { :taxonomy => :location }
    validates :subnet6, :belongs_to_host_taxonomy => { :taxonomy => :location }
    validates :subnet, :belongs_to_host_taxonomy => { :taxonomy => :organization }
    validates :subnet6, :belongs_to_host_taxonomy => { :taxonomy => :organization }

    validate :check_blank_mac_for_virtual_resources, on: :create

    scope :bmc, -> { where(:type => "Nic::BMC") }
    scope :bonds, -> { where(:type => "Nic::Bond") }
    scope :bridges, -> { where(:type => "Nic::Bridge") }
    scope :interfaces, -> { where(:type => "Nic::Interface") }
    scope :managed, -> { where(:type => "Nic::Managed") }

    scope :virtual, -> { where(:virtual => true) }
    scope :physical, -> { where(:virtual => false) }
    scope :is_managed, -> { where(:managed => true) }

    scope :primary, -> { where(:primary => true) }
    scope :provision, -> { where(:provision => true) }

    belongs_to :subnet, -> { where :type => 'Subnet::Ipv4' }
    belongs_to :subnet6, -> { where :type => 'Subnet::Ipv6' }, :class_name => "Subnet"
    belongs_to :domain

    belongs_to_host :inverse_of => :interfaces, :class_name => "Host::Base"

    scoped_search :on => :mac, :complete_value => true, :only_explicit => true
    scoped_search :on => :ip, :complete_value => true, :only_explicit => true
    scoped_search :on => :name, :complete_value => true, :only_explicit => true
    scoped_search :on => :managed, :complete_value => {:true => true, :false => false}, :only_explicit => true
    scoped_search :on => :primary, :complete_value => {:true => true, :false => false}, :only_explicit => true
    scoped_search :on => :domain_id, :complete_value => true, :only_explicit => true

    # keep extra attributes needed for sub classes.
    serialize :attrs, Hash

    # provider specific attributes
    serialize :compute_attributes, Hash

    class Jail < ::Safemode::Jail
      allow :id, :managed?, :subnet, :subnet6, :virtual?, :physical?, :mac, :ip, :ip6, :identifier, :attached_to,
        :link, :tag, :domain, :vlanid, :mtu, :bond_options, :attached_devices, :mode,
        :attached_devices_identifiers, :primary, :provision, :alias?, :inheriting_mac,
        :children_mac_addresses, :nic_delay, :fqdn, :shortname, :type, :managed?, :bond?, :bridge?, :bmc?
    end

    # include STI inheritance column in audits
    def self.default_ignored_attributes
      super - [inheritance_column]
    end

    def physical?
      !virtual?
    end

    def bond?
      type == 'Nic::Bond'
    end

    def bridge?
      type == 'Nic::Bridge'
    end

    def bmc?
      type == 'Nic::BMC'
    end

    def type_name
      type.split("::").last
    end

    def self.humanized_name
      # provide class name as a default value
      name.split("::").last
    end

    def self.type_by_name(name)
      allowed_types.find { |nic_class| nic_class.humanized_name.downcase == name.to_s.downcase }
    end

    # NIC types have to be registered to expose them to users
    def self.register_type(type)
      allowed_types << type
    end

    def self.allowed_types
      @allowed_types ||= []
    end

    # after every name change, we synchronize it to host object
    def name=(*args)
      result = super
      sync_name
      result
    end

    def hostname
      if domain.present? && name.present?
        "#{shortname}.#{domain.name}"
      else
        name
      end
    end

    def shortname
      if domain
        name.to_s.chomp("." + domain.name)
      elsif domain_id && (unscoped_domain = Domain.unscoped.find_by(id: domain_id))
        # If domain is nil, but domain_id is set, domain could be
        # in another taxonomy.  Don't fail to create a correct shortname.
        name.to_s.chomp("." + unscoped_domain.name)
      else
        name
      end
    end

    def validated?
      !!@validated
    end

    # we should guarantee the fqdn is always fully qualified
    def fqdn
      return name if name.blank? || domain.blank?
      name.include?('.') ? name : "#{name}.#{domain}"
    end

    def clone
      # do not copy system specific attributes
      deep_clone(:except => [:name, :mac, :ip, :ip6, :host_id])
    end

    # if this interface does not have MAC and is attached to other interface,
    # we can fetch mac from this other interface
    def inheriting_mac
      mac.presence || host.interfaces.detect { |i| i.identifier == attached_to }.try(:mac)
    end

    # if this interface has attached devices (e.g. in a bond),
    # we can get the mac addresses from the children
    def children_mac_addresses
      []
    end

    # we don't consider host as managed if we are in non-unattended mode
    # in which case host managed? flag can be true but we should consider
    # everything as unmanaged
    def host_managed?
      host&.managed? && SETTINGS[:unattended]
    end

    def require_ip4_validation?(from_compute = true)
      NicIpRequired::Ipv4.new(:nic => self, :from_compute => from_compute).required?
    end

    def require_ip6_validation?(from_compute = true)
      NicIpRequired::Ipv6.new(:nic => self, :from_compute => from_compute).required?
    end

    def required_ip_addresses_set?(from_compute = true)
      errors.add(:ip, :blank) if ip.blank? && require_ip4_validation?(from_compute)
      errors.add(:ip6, :blank) if ip6.blank? && require_ip6_validation?(from_compute)
      !errors.include?(:ip) && !errors.include?(:ip6)
    end

    def compute_provides_ip?(field)
      return false unless managed? && host_managed? && primary?
      subnet_field = (field == :ip6) ? :subnet6 : :subnet
      host.compute_provides?(field) || host.compute_provides?(:mac) && mac_based_ipam?(subnet_field)
    end

    def mac_based_ipam?(subnet_field)
      send(subnet_field).present? && send(subnet_field).ipam == IPAM::MODES[:eui64]
    end

    # Overwrite setter for ip to force normalization
    # even when address is set during a callback
    def ip=(addr)
      super(Net::Validations.normalize_ip(addr))
    end

    # Overwrite setter for ip6 to force normalization
    # even when address is set during a callback
    def ip6=(addr)
      super(Net::Validations.normalize_ip6(addr))
    end

    def matches_subnet?(ip_field, subnet_field)
      return unless send(subnet_field).present?
      ip_value = send(ip_field)
      ip_value.present? && public_send(subnet_field).contains?(ip_value)
    end

    def to_audit_label
      return "#{name} (#{identifier})" if name.present? && identifier.present?
      return "#{mac} (#{identifier})" if mac.present? && identifier.present?
      [mac, name, identifier, _('Unnamed')].detect(&:present?)
    end

    protected

    def normalize_mac
      self.mac = Net::Validations.normalize_mac(mac)
      true
    rescue Net::Validations::Error => e
      errors.add(:mac, e.message)
    end

    def valid_domain
      unless Domain.find_by_id(domain_id)
        errors.add(:domain_id, _("can't find domain with this id"))
      end
    end

    def set_validated
      @validated = true
    end

    # do we require a host object associate to the interface? defaults to true
    def require_host?
      true
    end

    def not_required_interface
      if host&.managed? && !host.being_destroyed?
        if primary?
          errors.add :primary, _("can't delete primary interface of managed host")
        end
        if provision?
          errors.add :provision, _("can't delete provision interface of managed host")
        end
      end
      throw :abort if errors[:primary].present? || errors[:provision].present?
    end

    def exclusive_primary_interface
      if host && primary?
        primaries = host.interfaces.select { |i| i.primary? && i != self }
        errors.add :primary, _("host already has primary interface") unless primaries.empty?
      end
    end

    def exclusive_provision_interface
      if host && provision?
        provisions = host.interfaces.select { |i| i.provision? && i != self }
        errors.add :provision, _("host already has provision interface") unless provisions.empty?
      end
    end

    def sync_name
      synchronizer = NameSynchronizer.new(self)
      synchronizer.sync_name if synchronizer.sync_required?
    end

    def validate_subnet_types
      errors.add(:subnet, _("must be of type Subnet::Ipv4.")) if subnet.present? && subnet.type != 'Subnet::Ipv4'
      errors.add(:subnet6, _("must be of type Subnet::Ipv6.")) if subnet6.present? && subnet6.type != 'Subnet::Ipv6'
    end

    def mac_uniqueness
      interface_attribute_uniqueness(:mac, Nic::Base.physical.is_managed)
    end

    def validate_mac_is_unicast
      errors.add(:mac, _('must be a unicast MAC address')) if Net::Validations.multicast_mac?(mac) || Net::Validations.broadcast_mac?(mac)
    end

    def validate_updating_types
      sti_type = type || 'Nic::Base'
      errors.add(:type, _("can't be changed once the interface is saved")) if persisted? && (self.class.name != sti_type)
    end

    def mac_addresses_for_provisioning
      [mac, children_mac_addresses].flatten.compact.uniq
    end

    private

    def interface_attribute_uniqueness(attr, base = Nic::Base.where(nil))
      in_memory_candidates = host.present? ? host.interfaces.select { |i| i.persisted? && !i.marked_for_destruction? } : [self]
      db_candidates = base.where(attr => public_send(attr))
      db_candidates = db_candidates.select { |c| c.id != id && in_memory_candidates.map(&:id).include?(c.id) }
      errors.add(attr, :taken) if db_candidates.present?
    end

    def check_blank_mac_for_virtual_resources
      if virtual? && host.try(:compute_provides?, :mac) && host.uuid.empty? && mac.present?
        errors.add(:mac, _("can't be set for this interface because it's provided by the compute resource"))
      end
    end
  end
end

require_dependency 'nic/interface'
