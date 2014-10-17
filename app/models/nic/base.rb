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
                    :managed, :bond_options, :attached_devices, :mode
                    :_destroy # used for nested_attributes

    before_validation :normalize_mac

    validates :mac, :uniqueness => {:scope => :virtual}, :unless => :virtual?
    validates :mac, :presence => true, :unless => :virtual?
    validates :mac, :mac_address => true, :allow_blank => true

    validate :uniq_with_hosts

    validates :host, :presence => true, :if => Proc.new { |nic| nic.require_host? }

    scope :bootable, lambda { where(:type => "Nic::Bootable") }
    scope :bmc, lambda { where(:type => "Nic::BMC") }
    scope :bonds, lambda { where(:type => "Nic::Bond") }
    scope :interfaces, lambda { where(:type => "Nic::Interface") }
    scope :managed, lambda { where(:type => "Nic::Managed") }

    scope :virtual, lambda { where(:virtual => true) }
    scope :physical, lambda { where(:virtual => false) }
    scope :is_managed, lambda { where(:managed => true) }

    belongs_to_host :inverse_of => :interfaces, :class_name => "Host::Base"
    # keep extra attributes needed for sub classes.
    serialize :attrs, Hash

    class Jail < ::Safemode::Jail
      allow :managed?, :subnet, :virtual?, :mac, :ip, :identifier, :attached_to,
            :link, :tag, :domain, :vlanid, :bond_options, :attached_devices, :mode,
            :attached_devices_identifiers
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
          if host.send(attr) == value
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
    end

    # do we require a host object associate to the interface? defaults to true
    def require_host?
      true
    end

  end

end

require_dependency 'nic/interface'
