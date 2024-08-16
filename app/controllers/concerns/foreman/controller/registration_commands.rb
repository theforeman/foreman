module Foreman::Controller::RegistrationCommands
  extend ActiveSupport::Concern

  private

  MIN_VALUE = 0
  MAX_VALUE = 999999
  DEFAULT_VALUE = 4

  def command
    args_query = "?#{registration_args.to_query}"
    "set -o pipefail && curl -sS #{insecure} '#{registration_url(@smart_proxy)}#{args_query if args_query != '?'}' #{command_headers} | bash"
  end

  def registration_args
    params = registration_params
    if jwt_expiration_param > 0
      expires = Time.now.utc + jwt_expiration_param.hours
      params = params.merge(expires_at_utc: expires.to_i)
    end
    params.except(*ignored_query_args)
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

  def invalid_expiration_error
    raise ::Foreman::Exception.new(N_("Invalid value '%{value}' for jwt_expiration. The value must be between %{minimum} and %{maximum}. 0 means 'unlimited'."), { value: registration_params['jwt_expiration'], minimum: MIN_VALUE, maximum: MAX_VALUE })
  end

  def jwt_expiration_param
    param = registration_params['jwt_expiration'] || DEFAULT_VALUE
    @jwt_expiration_param ||= begin
      if param == 'unlimited'
        0
      elsif Float(param, exception: false)
        param.to_i
      else
        invalid_expiration_error
      end
    end
  end

  def expiration_unlimited?
    jwt_expiration_param == 0
  end

  def expiration_valid?
    jwt_expiration_param.between?(MIN_VALUE, MAX_VALUE)
  end

  def command_headers
    jwt_args = {
      scope: [{ controller: :registration, actions: [:global, :host] }],
    }
    if expiration_valid?
      jwt_args[:expiration] = jwt_expiration_param.hours.to_i unless expiration_unlimited?
    else
      invalid_expiration_error
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
