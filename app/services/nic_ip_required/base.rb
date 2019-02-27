module NicIpRequired
  class Base
    attr_reader :nic, :from_compute, :subnet, :field, :other_field

    delegate :logger, :to => :Rails
    delegate :host, :domain, :to => :nic

    def initialize(opts = {})
      @nic = opts.fetch(:nic)

      # the compute resource can provide an IP, so don't validate yet
      @from_compute = opts.fetch(:from_compute, true)
    end

    def required?
      # if it's not managed there's nowhere to specify an IP anyway
      return false unless nic_managed?

      # if the CR will provide an IP, then don't validate yet
      return false if compute_provides_ip?

      [require_ip_for_dns?, require_ip_for_dhcp?, require_ip_instead_of_token?].any?
    end

    def nic_managed?
      nic.host_managed? && nic.managed? && nic.provision?
    end

    def require_ip_for_dns?
      reverse_dns? || forward_dns?
    end

    def reverse_dns?
      subnet.present? && subnet.dns_id.present?
    end

    def forward_dns?
      domain.present? && domain.dns_id.present? && !other_ip_protocol_provides_ip?
    end

    def require_ip_for_dhcp?
      subnet.present? && subnet.dhcp_id.present?
    end

    def require_ip_instead_of_token?
      tokens_disabled? && unattended_controller_used? && !other_ip_protocol_provides_ip?
    end

    def tokens_disabled?
      Setting[:token_duration] == 0
    end

    def unattended_controller_used?
      !host.image_build? || (host.image_build? && host.image.try(:user_data?))
    end

    def compute_provides_ip?
      from_compute && nic.compute_provides_ip?(field)
    end

    def other_ip_protocol_provides_ip?
      nic.send(other_field).present? || nic.compute_provides_ip?(other_field)
    end
  end
end
