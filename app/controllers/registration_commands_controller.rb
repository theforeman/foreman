class RegistrationCommandsController < ApplicationController
  include Foreman::Controller::RegistrationCommands

  def form_data
    render json: {
      organizations: User.current.my_organizations.select(:id, :name),
      locations: User.current.my_locations.select(:id, :name),
      hostGroups: Hostgroup.authorized(:view_hostgroups).includes([:operatingsystem]),
      operatingSystems: Operatingsystem.authorized(:view_operatingsystems),
      smartProxies: Feature.find_by(name: 'Registration')&.smart_proxies,
      configParams: host_config_params,
      pluginData: plugin_data,
    }
  end

  def operatingsystem_template
    os = Operatingsystem.authorized(:view_operatingsystems).find(params[:id])
    template_kind = TemplateKind.find_by(name: 'host_init_config')
    template = os.os_default_templates
                 .find_by(template_kind: template_kind)&.provisioning_template

    if template
      render json: { template: { name: template.name, path: edit_provisioning_template_path(template) } }
    else
      render json: { template: { name: nil, os_path: edit_operatingsystem_path(os)} }
    end
  end

  def create
    render json: { command: command }
  end

  private

  def ignored_query_args
    ['utf8', 'authenticity_token', 'commit', 'action', 'locale', 'controller', 'jwt_expiration', 'smart_proxy_id', 'insecure']
  end

  def registration_params
    if params['registration_command']
      params['registration_command'].transform_keys(&:underscore)
    else
      params
    end
  end

  # Extension point for plugins
  def plugin_data
    {}
  end
end
