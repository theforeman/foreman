module Foreman
  module UnattendedInstallation
    class HostVerifier
      attr_reader :errors, :host, :request_ip, :for_host_template, :controller_name

      def initialize(host, request_ip:, for_host_template:)
        @host = host
        @errors = []
        @for_host_template = for_host_template
        @request_ip = request_ip
        @controller_name = 'unattended'
      end

      def valid?
        return false unless valid_host_token?
        return false unless host_found?
        return false unless host_os?
        return false unless host_os_family?

        true
      end

      private

      # In case the token expires during installation
      # Only relevant when the verifier is being used with `for_host_template`
      def valid_host_token?
        return true unless for_host_template
        return true unless @host&.token_expired?

        errors << {
          message: N_('%{controller}: provisioning token for host %{host} expired'),
          type: :precondition_failed,
          params: { host: @host.name, controller: controller_name },
        }

        false
      end

      def host_found?
        return true if host.present?

        errors << {
          message: N_("%{controller}: unable to find a host that matches the request from %{addr}"),
          type: :not_found,
          params: { addr: request_ip, controller: controller_name },
        }

        false
      end

      def host_os?
        return true if host.operatingsystem

        errors << {
          message: N_("%{controller}: %{host}'s operating system is missing"),
          type: :conflict,
          params: { host: host.name, controller: controller_name },
        }

        false
      end

      def host_os_family?
        return true if host.operatingsystem.family

        errors << {
          message: N_("%{controller}: %{host}'s operating system %{os} has no OS family"),
          type: :conflict,
          params: { host: host.name, os: host.operatingsystem.fullname, controller: controller_name },
        }

        false
      end
    end
  end
end
