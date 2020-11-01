class RegistrationController < ApplicationController
  include Foreman::Controller::Registration

  def new
    form_options
  end

  def create
    form_options
    args_query = "?#{registration_args.to_query}"
    @command = "curl -X GET \"#{endpoint}#{args_query if args_query != '?'}\" #{headers} | bash"
  end

  private

  def form_options
    @host_groups = Hostgroup.authorized(:view_hostgroups).select(:id, :name)
    @operating_systems = Operatingsystem.authorized(:view_operatingsystems).select(:id, :title)
    @smart_proxies = Feature.find_by(name: 'Registration')&.smart_proxies || []
  end

  def headers
    hours = (params[:jwt_expiration].presence || 4).to_i.hours.to_i
    jwt = User.current.jwt_token!(expiration: hours)

    "-H 'Authorization: Bearer #{jwt}'"
  end

  def endpoint
    return global_registration_url if params['smart_proxy'].blank?

    proxy = SmartProxy.authorized(:view_smart_proxies).find(params[:smart_proxy])
    "#{proxy.url}/register"
  end

  def registration_args
    ignored = ['utf8', 'authenticity_token', 'commit', 'action', 'locale', 'controller', 'jwt_expiration']
    args = params.except(*ignored)
    args[:setup_insights] = setup_insights_param if params['setup_insights'].to_s.present?
    args[:setup_remote_execution] = setup_remote_execution_param if params['setup_remote_execution'].to_s.present?

    args.delete_if { |_, v| v.blank? }
        .permit!
  end

  def setup_insights_param
    global_setup_insights(host_config_params(*host_args)).to_s
  end

  def setup_remote_execution_param
    global_setup_remote_execution(host_config_params(*host_args)).to_s
  end

  def host_args
    organization = Organization.authorized(:view_organizations).find(params['organization_id']) if params['organization_id'].present?
    location = Location.authorized(:view_locations).find(params['location_id']) if params['location_id'].present?
    host_group = Hostgroup.authorized(:view_hostgroups).find(params['host_group_id']) if params["host_group_id"].present?
    operatingsystem = Operatingsystem.authorized(:view_operatingsystems).find(params['operatingsystem_id']) if params["operatingsystem_id"].present?

    [organization, location, host_group, operatingsystem]
  end
end
