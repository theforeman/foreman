# Represents a Host's network interface
# This class is the both parent
module Nic
  class Base < ActiveRecord::Base
    include Foreman::STI
    include Encryptable
    encrypts :password

    self.table_name = 'nics'

    validates_lengths_from_database

    before_validation :normalize_mac
    after_validation :set_validated
    before_destroy :not_required_interface

    validate :mac_uniqueness,
             :if => Proc.new { |nic| nic.managed? && nic.host && nic.host.managed? && !nic.host.compute? && !nic.virtual? && nic.mac.present? }
    validates :mac, :presence => true,
              :if => Proc.new { |nic| nic.managed? && nic.host_managed? && !nic.host.compute? && !nic.virtual? }
    validate :validate_mac_is_unicast,
              :if => Proc.new { |nic| nic.managed? && !nic.virtual? }
    validates :mac, :mac_address => true, :allow_blank => true

    validates :host, :presence => true, :if => Proc.new { |nic| nic.require_host? }

    validates :identifier, :uniqueness => { :scope => :host_id },
      :if => ->(nic) { nic.identifier.present? && nic.host && !nic.identifier_was.present? }

    validate :exclusive_primary_interface
    validate :exclusive_provision_interface
    validates :domain, :presence => true, :if => Proc.new { |nic| nic.host_managed? && nic.primary? }
    validate :valid_domain, :if => Proc.new { |nic| nic.host_managed? && nic.primary? }
    validates :ip, :presence => true, :if => Proc.new { |nic| nic.host_managed? && nic.require_ip4_validation? }
    validates :ip6, :presence => true, :if => Proc.new { |nic| nic.host_managed? && nic.require_ip6_validation? }

    validate :validate_subnet_types

    # Validate that subnet's taxonomies are defined for nic's host
    Taxonomy.enabled_taxonomies.map(&:singularize).map(&:to_sym).each do |taxonomy|
      validates :subnet, :belongs_to_host_taxonomy => {:taxonomy => taxonomy }
      validates :subnet6, :belongs_to_host_taxonomy => {:taxonomy => taxonomy }
    end

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

    # keep extra attributes needed for sub classes.
    serialize :attrs, Hash

    # provider specific attributes
    serialize :compute_attributes, Hash

    class Jail < ::Safemode::Jail
      allow :managed?, :subnet, :subnet6, :virtual?, :physical?, :mac, :ip, :ip6, :identifier, :attached_to,
            :link, :tag, :domain, :vlanid, :bond_options, :attached_devices, :mode,
            :attached_devices_identifiers, :primary, :provision, :alias?, :inheriting_mac
    end

    def physical?
      !virtual?
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

    # NIC types have to be registered to to expose them to users
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

    def shortname
      domain.nil? ? name : name.to_s.chomp("." + domain.name)
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
      self.deep_clone(:except  => [:name, :mac, :ip, :ip6])
    end

    # if this interface does not have MAC and is attached to other interface,
    # we can fetch mac from this other interface
    def inheriting_mac
      if self.mac.nil? || self.mac.empty?
        self.host.interfaces.detect { |i| i.identifier == self.attached_to }.try(:mac)
      else
        self.mac
      end
    end

    # we don't consider host as managed if we are in non-unattended mode
    # in which case host managed? flag can be true but we should consider
    # everything as unmanaged
    def host_managed?
      self.host && self.host.managed? && SETTINGS[:unattended]
    end

    def require_ip_validation?(ip_field, other_ip_field, subnet_object)
      raise ::Foreman::Exception.new("invalid ip field: %s", ip_field) unless ip_field == :ip || ip_field == :ip6
      raise ::Foreman::Exception.new("invalid other ip field: %s", other_ip_field) unless other_ip_field == :ip || other_ip_field == :ip6

      # if it's not managed there's nowhere to specify an IP anyway
      return false unless self.host.managed? && self.managed? && self.provision?

      # if the CR will provide an IP, then don't validate yet
      return false if host.compute_provides?(ip_field)

      ip_for_dns   = (subnet_object.present? && subnet_object.dns_id.present?) || (domain.present? && domain.dns_id.present? && !self.send(other_ip_field).present?)
      ip_for_dhcp  = subnet_object.present? && subnet_object.dhcp_id.present?
      ip_for_token = Setting[:token_duration] == 0 && (host.pxe_build? || (host.image_build? && host.image.try(:user_data?))) && !self.send(other_ip_field).present?

      # Any of these conditions will require an IP, so chain with OR
      ip_for_dns || ip_for_dhcp || ip_for_token
    end

    def require_ip4_validation?
      require_ip_validation?(:ip, :ip6, subnet)
    end

    def require_ip6_validation?
      require_ip_validation?(:ip6, :ip, subnet6)
    end

    protected

    def normalize_mac
      self.mac = Net::Validations.normalize_mac(mac)
    rescue Net::Validations::Error => e
      self.errors.add(:mac, e.message)
    end

    def valid_domain
      unless Domain.find_by_id(domain_id)
        self.errors.add(:domain_id, _("can't find domain with this id"))
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
      if host && host.managed? && !host.being_destroyed?
        if self.primary?
          self.errors.add :primary, _("can't delete primary interface of managed host")
        end
        if self.provision?
          self.errors.add :provision, _("can't delete provision interface of managed host")
        end
      end
      !(self.errors[:primary].present? || self.errors[:provision].present?)
    end

    def exclusive_primary_interface
      if host && self.primary?
        primaries = host.interfaces.select { |i| i.primary? && i != self }
        errors.add :primary, _("host already has primary interface") unless primaries.empty?
      end
    end

    def exclusive_provision_interface
      if host && self.provision?
        provisions = host.interfaces.select { |i| i.provision? && i != self }
        errors.add :provision, _("host already has provision interface") unless provisions.empty?
      end
    end

    def sync_name
      synchronizer = NameSynchronizer.new(self)
      synchronizer.sync_name if synchronizer.sync_required?
    end

    def validate_subnet_types
      errors.add(:subnet, _("must be of type Subnet::Ipv4.")) if self.subnet.present? && self.subnet.type != 'Subnet::Ipv4'
      errors.add(:subnet6, _("must be of type Subnet::Ipv6.")) if self.subnet6.present? && self.subnet6.type != 'Subnet::Ipv6'
    end

    def mac_uniqueness
      interface_attribute_uniqueness(:mac, Nic::Base.physical.is_managed)
    end

    def validate_mac_is_unicast
      errors.add(:mac, _('must be a unicast MAC address')) if Net::Validations.multicast_mac?(mac) || Net::Validations.broadcast_mac?(mac)
    end

    private

    def interface_attribute_uniqueness(attr, base = Nic::Base.where(nil))
      in_memory_candidates = self.host.present? ? self.host.interfaces.select { |i| i.persisted? && !i.marked_for_destruction? } : [self]
      db_candidates = base.where(attr => self.public_send(attr))
      db_candidates = db_candidates.select { |c| c.id != self.id && in_memory_candidates.map(&:id).include?(c.id) }
      errors.add(attr, :taken) if db_candidates.present?
    end
  end
end

require_dependency 'nic/interface'
