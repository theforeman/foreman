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

    def register
      @host.setBuild
      template = rendered_registration_template
      render plain: template if template
    end

    private

    def find_host
      token = params[:token]
      jwt_payload = ForemanRegister::RegistrationToken.new(token).decode
      return render_error(message: 'Registration token is missing or invalid.') unless jwt_payload

      @host = Host::Managed.find_by!(id: jwt_payload['host_id'])
    end

    def skip_secure_headers
      SecureHeaders.opt_out_of_all_protection(request)
    end

    def render_error(message:, status: :bad_request, **kwargs)
      render plain: "#!/bin/sh\necho \"#{message % kwargs}\"\nexit 1\n", status: status
    end

    def rendered_registration_template
      template = @host.registration_template
      unless template
        render_error(
          message: 'Unable to find registration template for host %{host} running %{os}',
          status: :not_found,
          host: @host.name,
          os: @host.operatingsystem
        )
        return
      end
      safe_render(template)
    end

    def safe_render(template)
      template.render(host: @host, params: params)
    rescue StandardError => e
      Foreman::Logging.exception("Error rendering the #{template.name} template", e)
      render_error(
        message: 'There was an error rendering the %{name} template: %{error}',
        status: :internal_server_error,
        name: template.name,
        error: e.message
      )
      false
    end
  end
end
