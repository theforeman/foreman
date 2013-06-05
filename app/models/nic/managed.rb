module Nic
  class Managed < Interface
    include Orchestration
    include Orchestration::DHCP
    include Orchestration::DNS

    attr_accessible :name, :subnet_id, :subnet, :domain_id, :domain

    validates_uniqueness_of :name, :scope => :domain_id

    belongs_to :subnet
    belongs_to :domain

    delegate :vlanid, :network, :to => :subnet

    # Interface normally are not executed by them self, so we use the host queue and related methods.
    # this ensures our orchestration works on both a host and a managed interface
    delegate :progress_report_id, :require_ip_validation?, :overwrite?, :capabilities, :managed?, :compute_resource, :to => :host

    # this ensures we can create an interface even when there is no host queue
    # e.g. outside to Host nested attributes
    def queue_with_host
      if host
        logger.debug 'Using host queue'
        host.queue
      else
        logger.debug 'Using nic queue'
        queue_without_host
      end
    end
    alias_method_chain :queue, :host

    # returns a DHCP reservation object
    def dhcp_record
      return unless dhcp? or @dhcp_record
      @dhcp_record ||= Net::DHCP::Record.new(dhcp_attrs)
    end

    protected

    def uniq_fields_with_hosts
      [:mac, :ip, :name]
    end

    # returns a hash of dhcp record attributes
    def dhcp_attrs
      raise ::Foreman::Exception.new(N_("DHCP not supported for this NIC")) unless dhcp?
      {
        :hostname => name,
        :ip       => ip,
        :mac      => mac,
        :proxy    => subnet.dhcp_proxy,
        :network  => network
      }
    end
  end
end
