module Foreman::Controller::Puppet::HostsControllerExtensions
  extend ActiveSupport::Concern

  PUPPETMASTER_ACTIONS = [:externalNodes, :lookup]
  PUPPET_AJAX_REQUESTS = %w{hostgroup_or_environment_selected puppetclass_parameters}

  MULTIPLE_EDIT_ACTIONS = %w(select_multiple_environment update_multiple_environment
                             select_multiple_puppet_proxy update_multiple_puppet_proxy
                             select_multiple_puppet_ca_proxy update_multiple_puppet_ca_proxy)

  included do
    add_smart_proxy_filters PUPPETMASTER_ACTIONS, :features => ['Puppet']
    alias_method :ajax_request_for_puppet_host_extensions, :ajax_request

    before_action :ajax_request_for_puppet_host_extensions, :only => PUPPET_AJAX_REQUESTS
    before_action :taxonomy_scope_for_puppet_host_extensions, :only => PUPPET_AJAX_REQUESTS
    before_action :find_multiple_for_puppet_host_extensions, :only => MULTIPLE_EDIT_ACTIONS
    before_action :validate_multiple_puppet_proxy, :only => :update_multiple_puppet_proxy
    before_action :validate_multiple_puppet_ca_proxy, :only => :update_multiple_puppet_ca_proxy

    define_action_permission MULTIPLE_EDIT_ACTIONS, :edit

    set_callback :set_class_variables, :after, :set_puppet_class_variables
  end

  def hostgroup_or_environment_selected
    refresh_host
    set_class_variables(@host)
    Taxonomy.as_taxonomy @organization, @location do
      if @environment || @hostgroup
        render :partial => 'puppetclasses/class_selection', :locals => {:obj => @host}
      else
        logger.info "environment_id or hostgroup_id is required to render puppetclasses"
      end
    end
  end

  def puppetclass_parameters
    Taxonomy.as_taxonomy @organization, @location do
      render :partial => "puppetclasses/classes_parameters", :locals => { :obj => refresh_host}
    end
  end

  def select_multiple_environment
  end

  def update_multiple_environment
    # simple validations
    if params[:environment].nil? || (id = params["environment"]["id"]).nil?
      error _('No environment selected!')
      redirect_to(select_multiple_environment_hosts_path)
      return
    end

    ev = Environment.find_by_id(id)

    # update the hosts
    @hosts.each do |host|
      host.environment = (id == 'inherit' && host.hostgroup.present?) ? host.hostgroup.environment : ev
      host.save(:validate => false)
    end

    success _('Updated hosts: changed environment')
    redirect_back_or_to hosts_path
  end

  def environment_from_param
    # simple validations
    if params[:environment].nil? || (id = params["environment"]["id"]).nil?
      error _('No environment selected!')
      redirect_to(select_multiple_environment_hosts_path)
      return
    end

    id
  end

  def get_environment_id(env_params)
    env_params['id'] if env_params
  end

  def get_environment_for(host, id)
    if id == 'inherit' && host.hostgroup.present?
      host.hostgroup.environment
    else
      Environment.find_by_id(id)
    end
  end

  def validate_multiple_puppet_proxy
    validate_multiple_proxy(select_multiple_puppet_proxy_hosts_path)
  end

  def validate_multiple_puppet_ca_proxy
    validate_multiple_proxy(select_multiple_puppet_ca_proxy_hosts_path)
  end

  def validate_multiple_proxy(redirect_path)
    if params[:proxy].nil? || (proxy_id = params[:proxy][:proxy_id]).nil?
      error _('No proxy selected!')
      redirect_to(redirect_path)
      return false
    end

    if proxy_id.present? && !SmartProxy.find_by_id(proxy_id)
      error _('Invalid proxy selected!')
      redirect_to(redirect_path)
      false
    end
  end

  def update_multiple_proxy(proxy_type, host_update_method)
    proxy_id = params[:proxy][:proxy_id]
    if proxy_id
      proxy = SmartProxy.find_by_id(proxy_id)
    else
      proxy = nil
    end

    failed_hosts = {}

    @hosts.each do |host|
      host.send(host_update_method, proxy)
      host.save!
    rescue => error
      failed_hosts[host.name] = error
      message = _('Failed to set %{proxy_type} proxy for %{host}.') % {:host => host, :proxy_type => proxy_type}
      Foreman::Logging.exception(message, error)
    end

    if failed_hosts.empty?
      if proxy
        success _('The %{proxy_type} proxy of the selected hosts was set to %{proxy_name}') % {:proxy_name => proxy.name, :proxy_type => proxy_type}
      else
        success _('The %{proxy_type} proxy of the selected hosts was cleared.') % {:proxy_type => proxy_type}
      end
    else
      error n_("The %{proxy_type} proxy could not be set for host: %{host_names}.",
        "The %{proxy_type} puppet ca proxy could not be set for hosts: %{host_names}",
        failed_hosts.count) % {:proxy_type => proxy_type, :host_names => failed_hosts.map { |h, err| "#{h} (#{err})" }.to_sentence}
    end
    redirect_back_or_to hosts_path
  end

  def handle_proxy_messages(errors, proxy, proxy_type)
    if errors.empty?
      if proxy
        success _('The %{proxy_type} proxy of the selected hosts was set to %{proxy_name}.') % {:proxy_name => proxy.name, :proxy_type => proxy_type}
      else
        success _('The %{proxy_type} proxy of the selected hosts was cleared.') % {:proxy_type => proxy_type}
      end
    else
      error n_("The %{proxy_type} proxy could not be set for host: %{host_names}.",
        "The %{proxy_type} puppet ca proxy could not be set for hosts: %{host_names}",
        errors.count) % {:proxy_type => proxy_type, :host_names => errors.map { |h, err| "#{h} (#{err})" }.to_sentence}
    end
  end

  def select_multiple_puppet_proxy
  end

  def update_multiple_puppet_proxy
    update_multiple_proxy(_('Puppet'), :puppet_proxy=)
  end

  def select_multiple_puppet_ca_proxy
  end

  def update_multiple_puppet_ca_proxy
    update_multiple_proxy(_('Puppet CA'), :puppet_ca_proxy=)
  end

  def set_puppet_class_variables
    @environment = @host.environment
  end

  def taxonomy_scope_for_puppet_host_extensions
    taxonomy_scope
  end

  def find_multiple_for_puppet_host_extensions
    find_multiple
  end
end
