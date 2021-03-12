# frozen_string_literal: true

module ForemanRegister
  class HostsController < ::ForemanRegister::ApplicationController
    # Skip default filters
    FILTERS = [
      :require_login,
      :session_expiry,
      :update_activity_time,
      :set_taxonomy,
      :authorize,
      :verify_authenticity_token,
    ].freeze

    FILTERS.each do |f|
      skip_before_action f
    end

    before_action :set_admin_user
    before_action :skip_secure_headers
    before_action :find_host
    before_action :find_template

    def register
      unless @template
        msg = N_("Unable to find registration template for host %{host} running %{os}") % { host: @host.name, os: @host.operatingsystem }
        render_error(
          message: msg,
          status: :not_found,
          host: @host.name,
          os: @host.operatingsystem
        )
        return
      end

      @host.setBuild
      safe_render(@template)
    end

    private

    def find_host
      token = params[:token]
      jwt_payload = ForemanRegister::RegistrationToken.new(token).decode
      return render_error(message: N_('Registration token is missing or invalid.')) unless jwt_payload

      @host = Host::Managed.find_by!(id: jwt_payload['host_id'])
    end

    def skip_secure_headers
      SecureHeaders.opt_out_of_all_protection(request)
    end

    def render_error(message:, status: :bad_request, **kwargs)
      render plain: "#!/bin/sh\necho \"#{message % kwargs}\"\nexit 1\n", status: status
    end

    def find_template
      @template = @host.initial_configuration_template
    rescue ::Foreman::Exception
      render_error(message: N_('Host is not associated with an operating system'))
    end

    def safe_render(template)
      render plain: template.render(host: @host, params: params)
    rescue StandardError => e
      Foreman::Logging.exception("Error rendering the #{template.name} template", e)
      message = N_("There was an error rendering the %{name} template: %{error}") % { name: template.name, error: e }

      render_error(
        message: message,
        status: :internal_server_error,
        name: template.name,
        error: e.message
      )
    end
  end
end
