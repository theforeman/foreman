module Foreman::Controller::RegistrationCommands
  extend ActiveSupport::Concern

  private

  def command
    args_query = "?#{registration_args.to_query}"
    "curl -sS #{insecure} '#{registration_url(@smart_proxy)}#{args_query if args_query != '?'}' #{command_headers} | bash"
  end

  def registration_args
    registration_params.except(*ignored_query_args)
                       .transform_values! { |v| v == false ? v.to_s : v }
                       .delete_if { |_, v| v.blank? }
                       .permit!
  end

  def insecure
    registration_params['insecure'] ? '--insecure' : ''
  end

  def registration_url(proxy = nil)
    return global_registration_url unless proxy

    url = proxy.setting('Registration', 'registration_url').presence || proxy.url

    "#{url}/register"
  end

  def command_headers
    jwt_args = {
      scope: [{ controller: :registration, actions: [:global, :host] }],
    }

    if registration_params['jwt_expiration'].present?
      jwt_args[:expiration] = registration_params['jwt_expiration'].to_i.hours.to_i if registration_params['jwt_expiration'] != 'unlimited'
    else
      jwt_args[:expiration] = 4.hours.to_i
    end

    "-H 'Authorization: Bearer #{User.current.jwt_token!(**jwt_args)}'"
  end

  def host_config_params
    organization = User.current.my_organizations.find(registration_params['organization_id']) if registration_params['organization_id'].present?
    location = User.current.my_locations.find(registration_params['location_id']) if registration_params['location_id'].present?
    host_group = Hostgroup.authorized(:view_hostgroups).find(registration_params['hostgroup_id']) if registration_params["hostgroup_id"].present?
    operatingsystem = Operatingsystem.authorized(:view_operatingsystems).find(registration_params['operatingsystem_id']) if registration_params["operatingsystem_id"].present?

    Host.new(organization: organization, location: location, hostgroup: host_group, operatingsystem: operatingsystem).params
  end

  def find_smart_proxy
    @smart_proxy = SmartProxy.authorized(:view_smart_proxies).find(registration_params['smart_proxy_id'])
    features = @smart_proxy.features.map(&:name)

    unless features.include?('Registration') && features.include?('Templates')
      message = N_("Proxy lacks one of the following features: 'Registration', 'Templates'")
      render_error('custom_error', status: :unprocessable_entity, locals: { message: message }) and return
    end
  end
end
