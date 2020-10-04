module HostStatus
  class Status < ApplicationRecord
    prepend Foreman::STI

    self.table_name = 'host_status'

    belongs_to_host :inverse_of => :host_statuses

    validates :host, :presence => true
    validates :host_id, :uniqueness => {:scope => :type}
    validates :reported_at, :presence => true

    before_validation :update_timestamp, :if => ->(status) { status.reported_at.blank? }

    class Jail < ::Safemode::Jail
      allow :host, :to_global, :to_label, :status, :name, :relevant?
      allow_class_method :status_name, :humanized_name
    end

    def to_global(options = {})
      HostStatus::Global::OK
    end

    def to_label(options = {})
      raise NotImplementedError, "Method 'to_label' method needs to be implemented"
    end

    def to_status(options = {})
      raise NotImplementedError, "Method 'to_status' method needs to be implemented"
    end

    def self.status_name
      raise NotImplementedError, "Method 'status_name' method needs to be implemented"
    end

    def name
      self.class.status_name
    end

    def self.humanized_name
      status_name.underscore
    end

    def refresh!
      refresh
      save!
    end

    def refresh
      update_timestamp
      update_status
    end

    # Whether this status should be displayed to users, it may not be relevant for certain
    # types of hosts
    def relevant?(options = {})
      true
    end

    # a substatus is used by some other status in order to determine its own status
    # this type of status does not affect the global status
    def substatus?(options = {})
      false
    end

    def status_link
    end

    private

    def update_timestamp
      self.reported_at = Time.now.utc
    end

    def update_status
      self.status = to_status
    end
  end
end

require_dependency 'host_status/configuration_status'
require_dependency 'host_status/build_status'
