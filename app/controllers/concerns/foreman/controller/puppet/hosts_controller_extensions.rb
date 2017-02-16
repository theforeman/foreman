module Foreman::Controller::Puppet::HostsControllerExtensions
  extend ActiveSupport::Concern

  PUPPETMASTER_ACTIONS = [ :externalNodes, :lookup ]
  PUPPET_AJAX_REQUESTS = %w{hostgroup_or_environment_selected puppetclass_parameters}

  MULTIPLE_EDIT_ACTIONS = %w(select_multiple_environment update_multiple_environment
                             select_multiple_puppet_proxy_pool update_multiple_puppet_proxy_pool
                             select_multiple_puppet_ca_proxy_pool update_multiple_puppet_ca_proxy_pool)
  PUPPET_MULTIPLE_ACTIONS = %w(multiple_puppetrun update_multiple_puppetrun) + MULTIPLE_EDIT_ACTIONS

  included do
    add_smart_proxy_filters PUPPETMASTER_ACTIONS, :features => ['Puppet']
    alias_method :find_resource_for_puppet_host_extensions, :find_resource
    alias_method :ajax_request_for_puppet_host_extensions, :ajax_request

    before_action :ajax_request_for_puppet_host_extensions, :only => PUPPET_AJAX_REQUESTS
    before_action :find_resource_for_puppet_host_extensions, :only => [:puppetrun]
    before_action :taxonomy_scope_for_puppet_host_extensions, :only => PUPPET_AJAX_REQUESTS
    before_action :find_multiple_for_puppet_host_extensions, :only => PUPPET_MULTIPLE_ACTIONS
    before_action :validate_multiple_puppet_proxy_pool, :only => :update_multiple_puppet_proxy_pool
    before_action :validate_multiple_puppet_ca_proxy_pool, :only => :update_multiple_puppet_ca_proxy_pool

    define_action_permission ['puppetrun', 'multiple_puppetrun', 'update_multiple_puppetrun'], :puppetrun
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

  def multiple_puppetrun
    deny_access unless Setting[:puppetrun]
  end

  def update_multiple_puppetrun
    return deny_access unless Setting[:puppetrun]
    if @hosts.map(&:puppetrun!).uniq == [true]
      success _("Successfully executed, check reports and/or log files for more details")
    else
      error _("Some or all hosts execution failed, Please check log files for more information")
    end
    redirect_back_or_to hosts_path
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

  def validate_multiple_puppet_proxy_pool
    validate_multiple_proxy_pool(hosts_path)
  end

  def validate_multiple_puppet_ca_proxy_pool
    validate_multiple_proxy_pool(hosts_path)
  end

  def validate_multiple_proxy(redirect_path)
    Foreman::Deprecation.deprecation_warning('1.18', "This object is now assignd a Proxy SmartProxyPool instead of a Proxy, Please update your code to reflect this.")
    if params[:proxy].nil? || (proxy_id = params[:proxy][:proxy_id]).nil?
      error _('No proxy selected!')
      redirect_to(redirect_path)
      return false
    end

    if proxy_id.present? && !SmartProxy.find_by_id(proxy_id)
      error _('Invalid proxy selected!')
      redirect_to(redirect_path)
      return false
    end
  end

  def validate_multiple_proxy_pool(redirect_path)
    if params[:proxy_pool].nil? || (pool_id = params[:proxy_pool][:pool_id]).nil?
      error _('No proxy SmartProxyPool selected!')
      redirect_to(redirect_path)
      return false
    end

    if pool_id.present? && !SmartProxyPool.find_by_id(pool_id)
      error _('Invalid proxy SmartProxyPool selected!')
      redirect_to(redirect_path)
      return false
    end
  end

  def update_multiple_proxy(proxy_type, host_update_method)
    Foreman::Deprecation.deprecation_warning('1.18', "This object can now be assignd a Proxy SmartProxyPool instead of a Proxy, Please update your code to reflect this.")
    proxy_id = params[:proxy][:proxy_id]
    if proxy_id
      proxy = SmartProxy.find_by_id(proxy_id)
    else
      proxy = nil
    end

    failed_hosts = {}

    @hosts.each do |host|
      begin
        host.send(host_update_method, proxy)
        host.save!
      rescue => error
        failed_hosts[host.name] = error
        message = _('Failed to set %{proxy_type} proxy for %{host}.') % {:host => host, :proxy_type => proxy_type}
        Foreman::Logging.exception(message, error)
      end
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
               failed_hosts.count) % {:proxy_type => proxy_type, :host_names => failed_hosts.map {|h, err| "#{h} (#{err})"}.to_sentence}
    end
    redirect_back_or_to hosts_path
  end

  def update_multiple_proxy_pool(proxy_type, host_update_method)
    pool_id = params[:proxy_pool][:pool_id]
    if pool_id
      pool = SmartProxyPool.find_by_id(pool_id)
    else
      pool = nil
    end

    failed_hosts = {}

    @hosts.each do |host|
      begin
        host.send(host_update_method, pool)
        host.save!
      rescue => error
        failed_hosts[host.name] = error
        message = _('Failed to set %{proxy_type} proxy Pool for %{host}.') % {:host => host, :proxy_type => proxy_type}
        Foreman::Logging.exception(message, error)
      end
    end

    if failed_hosts.empty?
      if pool
        success _('The %{proxy_type} Proxy Pool of the selected hosts was set to %{proxy_pool}.') % {:proxy_pool => pool.hostname, :proxy_type => proxy_type}
      else
        success _('The %{proxy_type} Proxy Pool of the selected hosts was cleared.') % {:proxy_type => proxy_type}
      end
    else
      error n_("The %{proxy_type} proxy SmartProxyPool could not be set for host: %{host_names}.",
               "The %{proxy_type} puppet ca proxy SmartProxyPool could not be set for hosts: %{host_names}.",
               failed_hosts.count) % {:proxy_type => proxy_type, :host_names => failed_hosts.map {|h, err| "#{h} (#{err})"}.to_sentence}
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
               errors.count) % {:proxy_type => proxy_type, :host_names => errors.map {|h, err| "#{h} (#{err})"}.to_sentence}
    end
  end

  def select_multiple_puppet_proxy_pool
  end

  def update_multiple_puppet_proxy_pool
    update_multiple_proxy_pool(_('Puppet'), :puppet_proxy_pool=)
  end

  def select_multiple_puppet_ca_proxy_pool
  end

  def update_multiple_puppet_ca_proxy_pool
    update_multiple_proxy_pool(_('Puppet CA'), :puppet_ca_proxy_pool=)
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
