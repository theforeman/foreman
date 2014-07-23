# Represents a Host's network interface
# This class is the both parent
module Nic
  class Base < ActiveRecord::Base
    include Foreman::STI

    self.table_name = 'nics'

    validates_lengths_from_database
    attr_accessible :host_id, :host,
                    :mac, :name,
                    :_destroy # used for nested_attributes

    before_validation :normalize_mac

    validates :mac, :uniqueness => true, :presence => true, :mac_address => true

    validate :uniq_with_hosts

    validates :host, :presence => true

    scope :bootable, lambda { where(:type => "Nic::Bootable") }
    scope :bmc, lambda { where(:type => "Nic::BMC") }
    scope :interfaces, lambda { where(:type => "Nic::Interface") }
    scope :managed, lambda { where(:type => "Nic::Managed") }

    belongs_to_host :inverse_of => :interfaces, :class_name => "Host::Managed"
    # keep extra attributes needed for sub classes.
    serialize :attrs, Hash

    protected

    def uniq_fields_with_hosts
      [:mac]
    end

    # make sure we don't have a conflicting interface with an host record
    def uniq_with_hosts
      failed = false
      uniq_fields_with_hosts.each do |attr|
        value = self.send(attr)
        unless value.blank?
          if host.send(attr) == value
            errors.add(attr, _("Can't use the same value as the primary interface"))
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
  end
end
