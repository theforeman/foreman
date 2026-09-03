module Foreman
  module UnattendedInstallation
    class HostVerifier
      attr_reader :errors, :host, :request_ip, :for_host_template, :controller_name

      def initialize(host, request_ip:, for_host_template:, search_paths:, token: nil, needs_token: true)
        @host = host
        @errors = []
        @for_host_template = for_host_template
        @search_paths = search_paths
        @request_ip = request_ip
        @controller_name = 'unattended'
        @token = token
        @needs_token = needs_token
      end

      def valid?
        return false unless valid_host_token?
        return false unless host_found?
        return false unless host_os?
        return false unless host_os_family?

        true
      end

      private

      # Only relevant when the verifier is being used with `for_host_template`.
      #
      # For operating systems that enforce a provisioning token (e.g. Anaconda
      # based systems that can carry it on the kernel command line) a host in
      # build mode must present its valid token; matching the host by IP/MAC is
      # not sufficient. This closes the path where a building host would serve
      # its template to any IP/MAC-matched request that provides no token.
      #
      # For every other OS the historical behavior is kept: the token is only a
      # host-matching aid, so IP/MAC matching is allowed and the token is merely
      # checked for expiry in case it expired mid-installation.
      def valid_host_token?
        return true unless @needs_token
        return true unless for_host_template

        if token_required?
          return true if valid_token_provided?

          errors << {
            message: N_('%{controller}: a provisioning token is required for host %{host} but a valid one was not provided'),
            type: :unauthorized,
            params: { host: @host.name, controller: controller_name },
          }

          return false
        end

        return true unless @host&.token_expired?

        errors << {
          message: N_('%{controller}: provisioning token for host %{host} expired'),
          type: :unauthorized,
          params: { host: @host.name, controller: controller_name },
        }

        false
      end

      # Enforcement applies only to a host in build mode whose OS can carry the
      # token. It is inert when tokens are disabled globally, since no tokens are
      # generated in that mode (see Hostext::Token#set_token).
      def token_required?
        return false if Setting[:token_duration] == 0
        return false unless @host&.build?

        !!@host.operatingsystem&.token_enforced?
      end

      def valid_token_provided?
        return false if @token.blank?

        stored = @host&.token
        return false if stored.nil? || @host.token_expired?

        ActiveSupport::SecurityUtils.secure_compare(@token.to_s, stored.value.to_s)
      end

      def host_found?
        return true if host.present?
        errors << {
          message: N_("%{controller}: unable to find a host that matches the request from %{addr}. Search paths: %{search_paths}"),
          type: :not_found,
          params: { controller: controller_name, addr: request_ip, search_paths: @search_paths.join(',') },
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
