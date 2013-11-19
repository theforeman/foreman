module Nic
  class Managed < Interface
    include Orchestration
    include Orchestration::DHCP
    include Orchestration::DNS

    attr_accessible :name, :subnet_id, :subnet, :domain_id, :domain

    # Don't have to set a systemname for each interface, but it must be unique if it is set.
    validates :name, :uniqueness => {:scope => :domain_id}, :allow_nil => true, :allow_blank => true

    belongs_to :subnet
    belongs_to :domain

    delegate :vlanid, :network, :to => :subnet

    # Interface normally are not executed by them self, so we use the system queue and related methods.
    # this ensures our orchestration works on both a system and a managed interface
    delegate :progress_report_id, :require_ip_validation?, :overwrite?, :capabilities, :managed?, :compute_resource, :to => :system

    # this ensures we can create an interface even when there is no system queue
    # e.g. outside to System nested attributes
    def queue_with_system
      if system
        logger.debug 'Using system queue'
        system.queue
      else
        logger.debug 'Using nic queue'
        queue_without_system
      end
    end
    alias_method_chain :queue, :system

    # returns a DHCP reservation object
    def dhcp_record
      return unless dhcp? or @dhcp_record
      @dhcp_record ||= Net::DHCP::Record.new(dhcp_attrs)
    end

    protected

    def uniq_fields_with_systems
      [:mac, :ip, :name]
    end

    # returns a hash of dhcp record attributes
    def dhcp_attrs
      raise ::Foreman::Exception.new(N_("DHCP not supported for this NIC")) unless dhcp?
      {
        :systemname => name,
        :ip       => ip,
        :mac      => mac,
        :proxy    => subnet.dhcp_proxy,
        :network  => network
      }
    end
  end
end
