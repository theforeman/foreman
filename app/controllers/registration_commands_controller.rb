class RegistrationCommandsController < ApplicationController
  include Foreman::Controller::RegistrationCommands

  def new
    form_options
  end

  def create
    form_options
    @command = command
  end

  private

  def form_options
    @host_groups = Hostgroup.authorized(:view_hostgroups).select(:id, :name)
    @operating_systems = Operatingsystem.authorized(:view_operatingsystems).select(:id, :title)
    @smart_proxies = Feature.find_by(name: 'Registration')&.smart_proxies || []
  end

  def ignored_query_args
    ['utf8', 'authenticity_token', 'commit', 'action', 'locale', 'controller', 'jwt_expiration', 'smart_proxy_id', 'insecure']
  end

  def registration_params
    params
  end
end
