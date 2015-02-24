# Represents a Host's network interface
# This class is the both parent
module Nic
  class Base < ActiveRecord::Base
    include Foreman::STI

    self.table_name = 'nics'

    validates_lengths_from_database
    attr_accessible :host_id, :host,
                    :mac, :name,
                    :provider, :username, :password,
                    :identifier, :virtual, :link, :tag, :attached_to,
                    :managed, :bond_options, :attached_devices, :mode,
                    :primary, :provision, :compute_attributes,
                    :_destroy # used for nested_attributes

    before_validation :normalize_mac
    after_validation :set_validated
    before_destroy :not_required_interface

    validates :mac, :uniqueness => {:scope => :virtual},
              :if => Proc.new { |nic| nic.managed? && nic.host && nic.host.managed? && !nic.host.compute? && !nic.virtual? }, :allow_blank => true
    validates :mac, :presence => true,
              :if => Proc.new { |nic| nic.managed? && nic.host && nic.host.managed? && !nic.host.compute? &&!nic.virtual? }
    validates :mac, :mac_address => true, :allow_blank => true

    # TODO uniq on primary per host
    # validate :uniq_with_hosts

    validates :host, :presence => true, :if => Proc.new { |nic| nic.require_host? }

    validate :exclusive_primary_interface
    validate :exclusive_provision_interface
    validates :domain_id, :presence => true, :if => Proc.new { |nic| nic.host && nic.host.managed? && nic.primary? }
    validates :ip, :presence => true, :if => Proc.new { |nic| nic.host && nic.host.managed? && nic.require_ip_validation? }

    scope :bootable, lambda { where(:type => "Nic::Bootable") }
    scope :bmc, lambda { where(:type => "Nic::BMC") }
    scope :bonds, lambda { where(:type => "Nic::Bond") }
    scope :interfaces, lambda { where(:type => "Nic::Interface") }
    scope :managed, lambda { where(:type => "Nic::Managed") }

    scope :virtual, lambda { where(:virtual => true) }
    scope :physical, lambda { where(:virtual => false) }
    scope :is_managed, lambda { where(:managed => true) }

    scope :primary, lambda { { :conditions => { :primary => true } } }
    scope :provision, lambda { { :conditions => { :provision => true } } }

    belongs_to :subnet
    belongs_to :domain, :counter_cache => 'hosts_count'

    belongs_to_host :inverse_of => :interfaces, :class_name => "Host::Base"
    # do counter cache only for primary interfaces
    def belongs_to_counter_cache_after_create_for_domain
      super if self.primary
    end

    def belongs_to_counter_cache_before_destroy_for_domain
      super if self.primary
    end

    # keep extra attributes needed for sub classes.
    serialize :attrs, Hash

    # provider specific attributes
    serialize :compute_attributes, Hash

    class Jail < ::Safemode::Jail
      allow :managed?, :subnet, :virtual?, :mac, :ip, :identifier, :attached_to,
            :link, :tag, :domain, :vlanid, :bond_options, :attached_devices, :mode,
            :attached_devices_identifiers, :primary, :provision
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
      self.deep_clone(:except  => [:name, :mac, :ip])
    end

    protected

    def uniq_fields_with_hosts
      self.virtual? ? [] : [:mac]
    end

    # make sure we don't have a conflicting interface with an host record
    def uniq_with_hosts
      failed = false
      uniq_fields_with_hosts.each do |attr|
        value = self.send(attr)
        unless value.blank?
          if host && host.send(attr) == value
            errors.add(attr, _("can't use the same value as the primary interface"))
            failed = true
          elsif Host.where(attr => value).limit(1).pluck(attr).any?
            errors.add(attr, _("already in use"))
            failed = true
          end
        end
      end
      !failed
    end

    def normalize_mac
      self.mac = Net::Validations.normalize_mac(mac)
    rescue ArgumentError => e
      self.errors.add(:mac, e.message)
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

    def require_ip_validation?
      # if it's not managed there's nowhere to specify an IP anyway
      return false if !self.host.managed? || !self.managed? || !self.provision?
      # if the CR will provide an IP, then don't validate yet
      return false if host.compute_provides?(:ip)
      ip_for_dns     = (subnet.present? && subnet.dns_id.present?) || (domain.present? && domain.dns_id.present?)
      ip_for_dhcp    = subnet.present? && subnet.dhcp_id.present?
      ip_for_token   = Setting[:token_duration] == 0 && (host.pxe_build? || (host.image_build? && host.image.try(:user_data?)))
      # Any of these conditions will require an IP, so chain with OR
      ip_for_dns or ip_for_dhcp or ip_for_token
    end

    def sync_name
      synchronizer = NameSynchronizer.new(self)
      if synchronizer.sync_required?
        synchronizer.sync_name
      end
    end
  end
end

require_dependency 'nic/interface'
