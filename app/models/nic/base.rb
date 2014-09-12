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
                    :identifier, :virtual, :link, :tag, :physical_device,
                    :managed
                    :_destroy # used for nested_attributes

    before_validation :normalize_mac

    validates :mac, :uniqueness => {:scope => :virtual}, :if => Proc.new { |o| !o.virtual? }
    validates :mac, :presence => true, :mac_address => true

    validate :uniq_with_hosts

    validates :host, :presence => true, :if => Proc.new { |nic| nic.require_host? }

    scope :bootable, lambda { where(:type => "Nic::Bootable") }
    scope :bmc, lambda { where(:type => "Nic::BMC") }
    scope :interfaces, lambda { where(:type => "Nic::Interface") }
    scope :managed, lambda { where(:type => "Nic::Managed") }

    scope :virtual, lambda { where(:virtual => true) }
    scope :physical, lambda { where(:virtual => false) }

    belongs_to_host :inverse_of => :interfaces, :class_name => "Host::Base"
    # keep extra attributes needed for sub classes.
    serialize :attrs, Hash

    class Jail < ::Safemode::Jail
      allow :managed?, :subnet, :virtual?, :mac, :ip, :identifier, :physical_device,
            :link, :tag, :domain, :vlanid
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
