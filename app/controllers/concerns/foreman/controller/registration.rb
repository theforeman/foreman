module Foreman::Controller::Registration
  extend ActiveSupport::Concern

  def find_global_registration
    template_name = Setting[:default_global_registration_item]
    @provisioning_template = ProvisioningTemplate.unscoped.find_by(name: template_name)
    @global_registration_vars = global_registration_vars if @provisioning_template
  end

  private

  def global_registration_vars
    permitted = Foreman::Plugin.all
                               .map(&:allowed_registration_vars)
                               .flatten.compact.uniq

    organization = Organization.authorized(:view_organizations).find(params['organization_id']) if params['organization_id'].present?
    location = Location.authorized(:view_locations).find(params['location_id']) if params['location_id'].present?
    host_group = Hostgroup.authorized(:view_hostgroups).find(params['hostgroup_id']) if params["hostgroup_id"].present?
    operatingsystem = Operatingsystem.authorized(:view_operatingsystems).find(params['operatingsystem_id']) if params["operatingsystem_id"].present?

    params.permit(permitted)
          .to_h
          .symbolize_keys
          .merge({ user: User.current,
                   auth_token: User.current.jwt_token!(expiration: 4.hours.to_i),
                   organization: organization,
                   location: location,
                   hostgroup: host_group,
                   operatingsystem: operatingsystem })
  end

  def safe_render(template)
    render plain: template.render(host: @host, params: params)
  rescue StandardError => e
    Foreman::Logging.exception("Error rendering the #{template.name} template", e)
    message = N_("There was an error rendering the %{name} template: %{error}") % { name: template.name, error: e }

    render_error(message, status: :internal_server_error)
  end

  def render_error(error, options = {})
    locals_exception = options&.dig(:locals, :exception)
    locals_message = options&.dig(:locals, :message)
    output = <<~ERROR
      echo "ERROR: #{error}";
      #{"echo \"#{locals_exception}\";" if locals_exception}
      #{"echo \"#{locals_message}\";" if locals_message}
      exit 1
    ERROR

    render plain: output.squeeze("\n"), status: options[:status]
  end

  def not_found(options = nil)
    nf_opts = { locals: {} }
    nf_opts[:status] = :not_found

    case options
    when String
      nf_opts[:locals][:message] = options
    when Hash
      nf_opts[:locals].merge! options
    else
      render_error 'not_found', nf_opts
      return false
    end

    render_error 'not_found', nf_opts

    false
  end
end
