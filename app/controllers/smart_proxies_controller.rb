class SmartProxiesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::SmartProxy

  before_action :find_resource, :only => [:show, :edit, :update, :refresh, :ping, :tftp_server, :destroy, :puppet_environments, :puppet_dashboard, :log_pane, :failed_modules, :errors_card, :modules_card, :expire_logs]
  before_action :find_status, :only => [:ping, :tftp_server, :puppet_environments]

  def index
    @smart_proxies = resource_base_search_and_page.includes(:features)
  end

  def show
  end

  def new
    @smart_proxy = SmartProxy.new
  end

  def create
    @smart_proxy = SmartProxy.new(smart_proxy_params)
    if @smart_proxy.save
      process_success :object => @smart_proxy
    else
      process_error :object => @smart_proxy
    end
  end

  def edit
    @proxy = @smart_proxy
  end

  def refresh
    old_features = @smart_proxy.features.to_a
    if @smart_proxy.refresh.blank? && @smart_proxy.save
      msg = @smart_proxy.features.to_a == old_features ? _("No changes found when refreshing features from %s.") : _("Successfully refreshed features from %s.")
      process_success :object => @smart_proxy, :success_msg => msg % @smart_proxy.name
    else
      process_error :object => @smart_proxy
    end
  end

  def ping
    requested_data do
      @proxy_status[:version].version
    end
  end

  def tftp_server
    if @proxy_status[:tftp]
      requested_data do
        @proxy_status[:tftp].server
      end
    else
      render(:json => {:success => false, :message => _('No TFTP feature')})
    end
  end

  def puppet_environments
    render :partial => 'smart_proxies/plugins/puppet_envs', :locals => {:envs => @proxy_status[:puppet].environment_stats}
  rescue Foreman::Exception => exception
    process_ajax_error exception
  end

  def puppet_dashboard
    @data = Dashboard::Data.new("puppet_proxy_id = \"#{@smart_proxy.id}\"")
    render :partial => 'smart_proxies/plugins/puppet_dashboard'
  rescue Foreman::Exception => exception
    process_ajax_error exception
  end

  def update
    if @smart_proxy.update_attributes(smart_proxy_params)
      process_success :object => @smart_proxy
    else
      process_error :object => @smart_proxy
    end
  end

  def destroy
    if @smart_proxy.destroy
      process_success :object => @smart_proxy, :success_redirect => smart_proxies_path
    else
      process_error :object => @smart_proxy
    end
  end

  def log_pane
    render :partial => 'smart_proxies/logs/list', :locals => {:log_entries => @smart_proxy.statuses[:logs].logs.log_entries}
  rescue Foreman::Exception => exception
    process_ajax_error exception
  end

  def expire_logs
    from = (params[:from].to_i rescue 0) || 0
    if from >= 0
      logger.debug "Expired smart-proxy logs, new timestamp is #{from}"
      @smart_proxy.expired_logs = from.to_s
      @smart_proxy.save!
    end
    @smart_proxy.statuses[:logs].revoke_cache!
    log_pane
  rescue Foreman::Exception => exception
    process_ajax_error exception
  end

  def failed_modules
    modules = @smart_proxy.statuses[:logs].logs.failed_modules || {}
    render :partial => 'smart_proxies/logs/failed_modules', :locals => {:modules => modules}
  rescue Foreman::Exception => exception
    process_ajax_error exception
  end

  def errors_card
    logs = @smart_proxy.statuses[:logs].logs
    render :partial => 'smart_proxies/logs/errors_card', :locals => {:logs => logs}
  rescue Foreman::Exception => exception
    process_ajax_error exception
  end

  def modules_card
    logs = @smart_proxy.statuses[:logs].logs
    render :partial => 'smart_proxies/logs/modules_card', :locals => {
      :logs => logs,
      :features => @smart_proxy.features,
      :features_started => @smart_proxy.features.count,
      :names => logs.failed_module_names
    }
  rescue Foreman::Exception => exception
    process_ajax_error exception
  end

  private

  def find_status
    @proxy_status = @smart_proxy.statuses
  end

  def requested_data
    data = yield
    render :json => {:success => true, :message => data }
  rescue Foreman::Exception => exception
    render :json => {:success => false, :message => exception.message}
  end

  def action_permission
    case params[:action]
      when 'refresh', 'expire_logs'
        :edit
      when 'ping', 'tftp_server', 'puppet_environments', 'puppet_dashboard', 'log_pane', 'failed_modules', 'errors_card', 'modules_card'
        :view
      else
        super
    end
  end

  def resource_base
    base = super
    base = base.eager_load(:locations) if SETTINGS[:locations_enabled]
    base = base.eager_load(:organizations) if SETTINGS[:organizations_enabled]
    base
  end
end
