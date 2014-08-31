module Nic
  class Managed < Interface
    include Orchestration
    include Orchestration::DHCP
    include Orchestration::DNS

    # Interface normally are not executed by them self, so we use the host queue and related methods.
    # this ensures our orchestration works on both a host and a managed interface
    delegate :progress_report_id, :require_ip_validation?, :overwrite?, :capabilities, :compute_resource,
             :image_build?, :pxe_build?, :pxe_build?, :ip_available?, :mac_available?, :to => :host

    # this ensures we can create an interface even when there is no host queue
    # e.g. outside to Host nested attributes
    def queue_with_host
      if host && host.respond_to?(:queue)
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

    def hostname
      if domain.present? && name.present?
        "#{name}.#{domain.name}"
      else
        name
      end
    end

    protected

    def uniq_fields_with_hosts
      super + [:name]
    end

    # returns a hash of dhcp record attributes
    def dhcp_attrs
      raise ::Foreman::Exception.new(N_("DHCP not supported for this NIC")) unless dhcp?
      {
        :hostname => hostname,
        :ip       => ip,
        :mac      => mac,
        :proxy    => subnet.dhcp_proxy,
        :network  => network
      }
    end

  end
end
