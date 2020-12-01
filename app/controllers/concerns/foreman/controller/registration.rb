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
    host_config_params = host_config_params(organization, location, host_group, operatingsystem)

    context = {
      user: User.current,
      auth_token: User.current.jwt_token!(expiration: 4.hours.to_i, scope: 'registration'),
      organization: (organization || User.current.default_organization || User.current.my_organizations.first),
      location: (location || User.current.default_location || User.current.my_locations.first),
      hostgroup: host_group,
      operatingsystem: operatingsystem,
      url_host: registration_url.host,
      registration_url: registration_url,
      setup_insights: global_setup_insights(host_config_params),
      setup_remote_execution: global_setup_remote_execution(host_config_params),
    }

    params.permit(permitted)
          .to_h
          .symbolize_keys
          .merge(context)
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

  def registration_url
    uri = if params[:url].present?
            URI.join(params[:url], '/register')
          else
            URI(register_url)
          end

    return uri if uri.scheme && uri.host

    msg = N_('URL in :url parameter is missing a scheme, please set http:// or https://')
    fail Foreman::Exception.new(msg)
  end

  def host_config_params(organization, location, host_group, operatingsystem)
    Host.new(organization: organization, location: location, hostgroup: host_group, operatingsystem: operatingsystem).params
  end

  def global_setup_insights(host_params)
    return if params['setup_insights'].to_s.blank?

    from_host = host_params['host_registration_insights']
    from_request = ActiveRecord::Type::Boolean.new.deserialize(params['setup_insights'])

    from_request if (from_request != from_host)
  end

  def global_setup_remote_execution(host_params)
    return if params['setup_remote_execution'].to_s.blank?

    from_host = host_params['host_registration_remote_execution']
    from_request = ActiveRecord::Type::Boolean.new.deserialize(params['setup_remote_execution'])

    from_request if (from_request != from_host)
  end

  def host_setup_insights
    return if params['setup_insights'].to_s.blank?

    insights_param = HostParameter.find_or_initialize_by(host: @host, name: 'host_registration_insights', key_type: 'boolean')
    insights_param.value = ActiveRecord::Type::Boolean.new.deserialize(params['setup_insights'])
    insights_param.save!
  end

  def host_setup_remote_execution
    return if params['setup_remote_execution'].to_s.blank?

    rex_param = HostParameter.find_or_initialize_by(host: @host, name: 'host_registration_remote_execution', key_type: 'boolean')
    rex_param.value = ActiveRecord::Type::Boolean.new.deserialize(params['setup_remote_execution'])
    rex_param.save!
  end
end
