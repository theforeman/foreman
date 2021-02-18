module Foreman::Controller::RegistrationCommands
  extend ActiveSupport::Concern

  private

  def command
    args_query = "?#{registration_args.to_query}"
    "curl #{insecure} -s '#{endpoint}#{args_query if args_query != '?'}' #{command_headers} | bash"
  end

  def registration_args
    args = registration_params.except(*ignored_query_args)
    args['setup_insights'] = registration_params['setup_insights']
    args['setup_remote_execution'] = registration_params['setup_remote_execution']

    args.delete_if { |_, v| v.blank? }
        .permit!
  end

  def insecure
    registration_params['insecure'] ? '--insecure' : ''
  end

  def endpoint
    return global_registration_url if registration_params['smart_proxy_id'].blank?

    proxy = SmartProxy.authorized(:view_smart_proxies).find(registration_params['smart_proxy_id'])
    "#{proxy.url}/register"
  end

  def command_headers
    hours = (registration_params['jwt_expiration'].presence || 4).to_i.hours.to_i
    scope = [{ controller: :registration, actions: [:global, :host] }]
    jwt = User.current.jwt_token!(expiration: hours, scope: scope)

    "-H 'Authorization: Bearer #{jwt}'"
  end
end
