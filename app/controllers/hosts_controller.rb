class HostsController < ApplicationController
  include Foreman::Controller::ActionPermissionDsl
  include ScopesPerAction
  include Foreman::Controller::HostDetails
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::TaxonomyMultiple
  include Foreman::Controller::SmartProxyAuth
  include Foreman::Controller::Parameters::Host
  include Foreman::Controller::HostFormCommon
  include Foreman::Controller::Puppet::HostsControllerExtensions
  include Foreman::Controller::CsvResponder
  include Foreman::Controller::ConsoleCommon

  SEARCHABLE_ACTIONS = %w[index active errors out_of_sync pending disabled]
  AJAX_REQUESTS = %w{compute_resource_selected current_parameters process_hostgroup process_taxonomy review_before_build scheduler_hint_selected interfaces}
  BOOT_DEVICES = { :disk => N_('Disk'), :cdrom => N_('CDROM'), :pxe => N_('PXE'), :bios => N_('BIOS') }
  MULTIPLE_ACTIONS = %w(multiple_parameters update_multiple_parameters select_multiple_hostgroup
                        update_multiple_hostgroup
                        multiple_destroy submit_multiple_destroy multiple_build
                        submit_multiple_build multiple_disable submit_multiple_disable
                        multiple_enable submit_multiple_enable
                        multiple_disassociate update_multiple_disassociate
                        rebuild_config submit_rebuild_config select_multiple_owner update_multiple_owner
                        select_multiple_power_state update_multiple_power_state)

  before_action :ajax_request, :only => AJAX_REQUESTS
  before_action :find_resource, :only => [:show, :clone, :edit, :update, :destroy, :review_before_build,
                                          :setBuild, :cancelBuild, :power, :overview, :bmc, :vm,
                                          :runtime, :resources, :nics, :ipmi_boot, :console,
                                          :toggle_manage, :pxe_config, :disassociate, :build_errors, :forget_status]

  before_action :taxonomy_scope, :only => [:new, :edit] + AJAX_REQUESTS
  before_action :set_host_type, :only => [:update]
  before_action :find_multiple, :only => MULTIPLE_ACTIONS
  before_action :validate_power_action, :only => :update_multiple_power_state

  helper :hosts, :reports, :interfaces

  def index(title = nil)
    begin
      search = action_scope_for(:index, resource_base_with_search)
    rescue => e
      error e.to_s
      search = resource_base.search_for ''
    end
    respond_to do |format|
      format.html do
        @hosts = search.includes(included_associations).paginate(:page => params[:page], :per_page => params[:per_page])
        # SQL optimizations queries
        @last_report_ids = ConfigReport.where(:host_id => @hosts.map(&:id)).group(:host_id).maximum(:id)
        @last_reports = ConfigReport.where(:id => @last_report_ids.values)
        # rendering index page for non index page requests (out of sync hosts etc)
        @hostgroup_authorizer = Authorizer.new(User.current, :collection => @hosts.map(&:hostgroup_id).compact.uniq)
        render :index if title && (@title = title)
      end
      format.csv do
        @hosts = search.preload(included_associations - [:host_statuses, :token])
        csv_response(@hosts)
      end
    end
  end

  def show
    respond_to do |format|
      format.html do
        # filter graph time range
        @range = (params["range"].empty? ? 7 : params["range"].to_i)

        # summary report text
        @report_summary = ConfigReport.summarise(@range.days.ago, @host)
      end
      format.yaml { render :plain => @host.info.to_yaml }
      format.json
    end
  end

  def new
    @host = Host.new(
      :managed => true,
      :build => true
    )
  end

  # Clone the host
  def clone
    @clone_host = @host
    @host = @clone_host.clone
    @host.build = true if @host.managed?
    load_vars_for_ajax
    warning(_("The marked fields will need reviewing"), true)
    @host.valid?
  end

  def create
    @host = Host.new(host_params)
    @host.managed = true if (params[:host] && params[:host][:managed].nil?)
    forward_url_options
    if @host.save
      process_success :success_redirect => host_path(@host)
    else
      load_vars_for_ajax
      offer_to_overwrite_conflicts
      process_error
    end
  end

  def edit
    load_vars_for_ajax
  end

  def update
    forward_url_options
    Taxonomy.no_taxonomy_scope do
      attributes = @host.apply_inherited_attributes(host_params)
      attributes.delete(:compute_resource_id)
      if @host.update(attributes)
        process_success :success_redirect => host_path(@host)
      else
        taxonomy_scope
        load_vars_for_ajax
        offer_to_overwrite_conflicts
        process_error
      end
    end
  end

  def destroy
    if @host.destroy
      process_success redirection_url_on_host_deletion
    else
      process_error :redirect => saved_redirect_url_or(send("#{controller_name}_url"))
    end
  end

  # form AJAX methods
  def random_name
    render :json => { :name => NameGenerator.new.next_random_name }
  rescue ActionView::Template::Error => exception
    process_ajax_error exception, 'generate random name'
  end

  def compute_resource_selected
    return not_found unless params[:host]
    Taxonomy.as_taxonomy @organization, @location do
      refresh_host
      compute_resource = ComputeResource.authorized(:view_compute_resources).find_by_id(@host.compute_resource_id) if @host.compute_resource_id
      return not_found if compute_resource.blank?
      @host.compute_attributes = compute_resource.compute_profile_attributes_for(@host.compute_profile_id || @host.hostgroup&.inherited_compute_profile_id)
      render partial: 'compute', locals: { host: @host, compute_resource: compute_resource }
    end
  rescue ActionView::Template::Error => exception
    process_ajax_error exception, 'render compute resource template'
  end

  def scheduler_hint_selected
    return not_found unless params[:host]
    refresh_host
    Taxonomy.as_taxonomy @organization, @location do
      render :partial => "compute_resources_vms/form/scheduler_hint_filters"
    end
  end

  def interfaces
    refresh_host
    @host.apply_compute_profile(InterfaceMerge.new)

    render :partial => "interfaces_tab"
  end

  def current_parameters
    host = refresh_host
    Taxonomy.as_taxonomy @organization, @location do
      render :partial => "common_parameters/inherited_parameters", :locals => {:inherited_parameters => host.inherited_params_hash, :parameters => host.host_parameters}
    end
  end

  # returns a yaml file ready to use for puppet external nodes script
  # expected a fqdn parameter to provide hostname to lookup
  # see example script in extras directory
  # will return HTML error codes upon failure

  def externalNodes
    certname = params[:name].to_s
    @host ||= resource_base.find_by_certname certname
    @host ||= resource_base.friendly.find certname
    unless @host
      not_found
      return
    end

    begin
      respond_to do |format|
        # don't break lines in yaml to support Ruby < 1.9.3
        # Remove the HashesWithIndifferentAccess using 'deep_stringify_keys',
        # then we turn it into YAML
        host_info_yaml = @host.info.deep_stringify_keys.to_yaml(:line_width => -1)
        format.html { render :html => "<pre>#{ERB::Util.html_escape(host_info_yaml)}</pre>".html_safe }
        format.yml { render :plain => host_info_yaml }
      end
    rescue => e
      Foreman::Logging.exception("Failed to generate external nodes for #{@host}", e)
      render :plain => _('Unable to generate output, Check log files'),
             :status => :precondition_failed
    end
  end

  def review_before_build
    @build = @host.build_status_checker
    render :layout => false
  end

  def setBuild
    forward_url_options
    if @host.setBuild
      if (params[:host] && params[:host][:build] == '1')
        begin
          if @host.power.reset
            message = _("Enabled %s for reboot and rebuild")
          else
            message = _("Enabled %s for rebuild on next boot, but failed to power cycle the host")
          end
          process_success :success_msg => message % @host, :success_redirect => :back
        rescue => error
          message = _('Failed to reboot %s.') % @host
          warning(message)
          Foreman::Logging.exception(message, error)
          process_success :success_msg => _("Enabled %s for rebuild on next boot") % @host, :success_redirect => :back
        end
      else
        process_success :success_msg => _("Enabled %s for rebuild on next boot") % @host, :success_redirect => :back
      end
    else
      process_error :redirect => :back, :error_msg => _("Failed to enable %{host} for installation: %{errors}") % { :host => @host, :errors => @host.errors.full_messages }
    end
  end

  def cancelBuild
    if @host.built(false)
      process_success :success_msg => _("Canceled pending build for %s") % @host.name, :success_redirect => :back
    else
      process_error :redirect => :back, :error_msg => _("Failed to cancel pending build for %{hostname} with the following errors: %{errors}") % {:hostname => @host.name, :errors => @host.errors.full_messages.join(', ')}
    end
  end

  def build_errors
    render :plain => @host.build_errors
  end

  def power
    return invalid_request unless PowerManager::REAL_ACTIONS.include?(params[:power_action])
    @host.power.send(params[:power_action].to_sym)
    process_success :success_redirect => :back, :success_msg => _("%{host} is about to %{action}") % { :host => @host, :action => _(params[:power_action].downcase) }
  rescue => e
    process_error :redirect => :back, :error_msg => _("Failed to %{action} %{host}: %{e}") % { :action => _(params[:power_action]), :host => @host, :e => e }
  end

  def overview
    render :partial => 'overview', :locals => { :host => @host }
  rescue ActionView::Template::Error => exception
    process_ajax_error exception, 'fetch overview information'
  end

  def bmc
    render :partial => 'bmc', :locals => {
      status: helpers.power_status(@host.power.state),
      bmc_proxy: @host.bmc_proxy,
    }
  rescue Foreman::BMCFeatureException
    render partial: 'bmc_missing_proxy', locals: { bmc_proxy: @host.subnet.bmc, bmc_count: SmartProxy.with_features('BMC').count }
  rescue Foreman::Exception => exception
    process_ajax_error exception, 'fetch bmc information'
  rescue ActionView::Template::Error => exception
    process_ajax_error exception, 'fetch bmc information'
  end

  def vm
    @vm = @host.compute_resource.find_vm_by_uuid(@host.uuid)
    @compute_resource = @host.compute_resource
    render :partial => "compute_resources_vms/details"
  rescue ActiveRecord::RecordNotFound, ActionView::Template::Error => exception
    process_ajax_error exception, 'fetch vm information'
  end

  def runtime
    render :partial => 'runtime'
  rescue ActionView::Template::Error => exception
    process_ajax_error exception, 'fetch runtime chart information'
  end

  def resources
    render :partial => 'resources'
  rescue ActionView::Template::Error => exception
    process_ajax_error exception, 'fetch resources chart information'
  end

  def templates
    find_templates
    render :partial => 'templates'
  rescue => exception
    process_ajax_error exception, 'fetch templates information'
  end

  def nics
    render :partial => 'nics'
  rescue ActionView::Template::Error => exception
    process_ajax_error exception, 'fetch interfaces information'
  end

  def forget_status
    status = @host.host_statuses.find(params[:status])
    status.delete
    redirect_to host_path(@host)
  end

  def ipmi_boot
    device    = params[:ipmi_device]
    device_id = BOOT_DEVICES.stringify_keys[device.downcase] || device
    @host.ipmi_boot(device)
    process_success :success_redirect => :back, :success_msg => _("%{host} now boots from %{device}") % { :host => @host.name, :device => _(device_id) }
  rescue => e
    process_error :redirect => :back, :error_msg => _("Failed to configure %{host} to boot from %{device}: %{e}") % { :device => _(device_id), :host => @host.name, :e => e }
  end

  def console
    return unless @host.compute_resource
    @console = @host.compute_resource.console @host.uuid
    super
  rescue => e
    Foreman::Logging.exception("Failed to set console", e)
    process_error :redirect => :back, :error_msg => _("Failed to set console: %s") % e
  end

  def toggle_manage
    if @host.toggle! :managed
      if @host.managed
        @host.suggest_default_pxe_loader
        msg = _("Foreman now manages the build cycle for %s") % @host.name
      else
        msg = _("Foreman now no longer manages the build cycle for %s") % @host.name
      end
      process_success :success_msg => msg, :success_redirect => :back
    else
      process_error :error_msg => _("Failed to modify the build cycle for %s") % @host.name, :redirect => :back
    end
  end

  def disassociate
    if @host.compute?
      @host.disassociate!
      process_success :success_msg => _("%s has been disassociated from VM") % @host.name, :success_redirect => :back
    else
      process_error :error_msg => _("Host %s is not associated with a VM") % @host.name, :redirect => :back
    end
  end

  def pxe_config
    redirect_to(:controller => "unattended", :action => 'host_template', :kind => "pxe_#{@host.operatingsystem.pxe_type}_config", :host_id => @host) if @host
  end

  # multiple host selection methods

  def multiple_parameters
    @parameters = HostParameter.where(:reference_id => @hosts).distinct.select("name")
  end

  def update_multiple_parameters
    if params[:name].empty?
      warning _("No parameters were allocated to the selected hosts, can't mass assign")
      redirect_to hosts_path
      return
    end

    @skipped_parameters = {}
    counter = 0
    @hosts.each do |host|
      skipped = []
      params[:name].each do |name, value|
        next if value.empty?
        if (host_param = host.host_parameters.friendly.find(name))
          counter += 1 if host_param.update_attribute(:value, value)
        else
          skipped << name
        end
        @skipped_parameters[host.name] = skipped unless skipped.empty?
      end
    end
    if @skipped_parameters.empty?
      success _('Updated all hosts!')
      redirect_to(hosts_path)
      nil
    else
      success _("%s Parameters updated, see below for more information") % counter
    end
  end

  def select_multiple_hostgroup
  end

  def update_multiple_hostgroup
    # simple validations
    unless (id = params["hostgroup"]["id"])
      error _('No host group selected!')
      redirect_to(select_multiple_hostgroup_hosts_path)
      return
    end
    hg = Hostgroup.find_by_id(id)
    # update the hosts
    @hosts.each do |host|
      host.hostgroup = hg
      host.save(:validate => false)
    end

    success _('Updated hosts: changed host group')
    # We prefer to go back as this does not lose the current search
    redirect_back_or_to hosts_path
  end

  def select_multiple_owner
  end

  def update_multiple_owner
    # simple validations
    if params[:owner].nil? || (id = params["owner"]["id"]).nil?
      error _('No owner selected!')
      redirect_to(select_multiple_owner_hosts_path)
      return
    end

    # update the hosts
    @hosts.each do |host|
      host.is_owned_by = id
      host.save(:validate => false)
    end

    success _('Updated hosts: changed owner')
    redirect_back_or_to hosts_path
  end

  def select_multiple_power_state
  end

  def update_multiple_power_state
    action = params[:power][:action]
    @hosts.each do |host|
      host.power.send(action.to_sym) if host.supports_power?
    rescue => error
      message = _('Failed to set power state for %s.') % host
      Foreman::Logging.exception(message, error)
    end

    success _('The power state of the selected hosts will be set to %s') % _(action)
    redirect_back_or_to hosts_path
  end

  def multiple_destroy
  end

  def multiple_build
  end

  def rebuild_config
  end

  def submit_rebuild_config
    all_fails = {}
    @hosts.each do |host|
      result = host.recreate_config
      result.each_pair do |k, v|
        all_fails[k] ||= []
        all_fails[k] << host.name unless v
      end
    end

    message = ''
    all_fails.each_pair do |key, values|
      unless values.empty?
        message << ((n_("%{config_type} rebuild failed for host: %{host_names}.",
          "%{config_type} rebuild failed for hosts: %{host_names}.",
          values.count) % {:config_type => _(key), :host_names => values.to_sentence})) + " "
      end
    end

    if message.blank?
      success _('Configuration successfully rebuilt')
    else
      error message
    end
    redirect_to hosts_path
  end

  def submit_multiple_build
    reboot = params[:host][:build] == '1' || false

    missed_hosts = @hosts.select do |host|
      success = true
      forward_url_options(host)
      begin
        host.setBuild
        host.power.reset if host.supports_power_and_running? && reboot
      rescue => error
        message = _('Failed to redeploy %s.') % host
        Foreman::Logging.exception(message, error)
        success = false
      end
      !success
    end

    if missed_hosts.empty?
      if reboot
        success _("The selected hosts were enabled for reboot and rebuild")
      else
        success _("The selected hosts will execute a build operation on next reboot")
      end
    else
      error _("The following hosts failed the build operation: %s") % missed_hosts.map(&:name).to_sentence
    end
    redirect_to(hosts_path)
  end

  def submit_multiple_destroy
    # keep all the ones that were not deleted for notification.
    missed_hosts = @hosts.select { |host| !host.destroy }
    if missed_hosts.empty?
      success _("Destroyed selected hosts")
    else
      error _("The following hosts were not deleted: %s") % missed_hosts.map(&:name).to_sentence
    end
    redirect_to(saved_redirect_url_or(send("#{controller_name}_url")))
  end

  def multiple_disable
  end

  def submit_multiple_disable
    toggle_hostmode false
  end

  def multiple_enable
  end

  def submit_multiple_enable
    toggle_hostmode
  end

  def multiple_disassociate
    @non_physical_hosts = @hosts.with_compute_resource
    @physical_hosts = @hosts.to_a - @non_physical_hosts.to_a
  end

  def update_multiple_disassociate
    @hosts.each do |host|
      host.disassociate!
    end
    success _('Updated hosts: Disassociated from VM')
    redirect_back_or_to hosts_path
  end

  def errors
    merge_search_filter("#{origin_intervals_query('>').join(' or ')} and (status.failed > 0 or status.failed_restarts > 0)")
    index _("Hosts with errors")
  end

  def active
    merge_search_filter("#{origin_intervals_query('>').join(' or ')} and (status.applied > 0 or status.restarted > 0)")
    index _("Active Hosts")
  end

  def pending
    merge_search_filter("#{origin_intervals_query('>').join(' or ')} and (status.pending > 0)")
    index _("Pending Hosts")
  end

  def out_of_sync
    merge_search_filter("#{origin_intervals_query('<').join(' or ')} and status.enabled = true")
    index _("Hosts which didn't report in the last %s") % reported_origin_interval_settings.map { |origin, interval| "#{interval} minutes for #{origin}" }.join(' or ')
  end

  def disabled
    merge_search_filter("status.enabled = false")
    index _("Hosts with notifications disabled")
  end

  def process_hostgroup
    @hostgroup = Hostgroup.find(params[:host][:hostgroup_id]) if params[:host][:hostgroup_id].to_i > 0
    return head(:not_found) unless @hostgroup
    refresh_host
    @host.attributes = @host.apply_inherited_attributes(host_params) unless @host.new_record?

    @host.set_hostgroup_defaults true
    @host.set_compute_attributes unless params[:host][:compute_profile_id]
    @host.apply_compute_profile(InterfaceMerge.new) if @host.compute_profile_id
    set_class_variables(@host)
    render :partial => "form"
  end

  def process_taxonomy
    return head(:not_found) unless @location || @organization
    refresh_host
    # revert compute resource to "Bare Metal" (nil) if selected
    # compute resource is not included taxonomy
    Taxonomy.as_taxonomy @organization, @location do
      # if compute_resource_id is not in our scope, reset it to nil.
      @host.compute_resource_id = nil unless ComputeResource.exists?(@host.compute_resource_id)
    end
    render :partial => 'form'
  end

  # on persisted record calling has_many `relations=` triggers saving/deletion immediately
  # so we have to filter such parameters
  # we don't need any has_many relation to determine what proxies are used and the view
  # renders only resulting templates set so the rest of form is unaffected
  def template_used
    host = params[:id] ? Host::Base.readonly.find(params[:id]) : Host.new
    kind = params.delete(:provisioning)
    host.attributes = host_attributes_for_templates(host)
    templates = host.available_template_kinds(kind)
    return not_found if templates.empty?
    render :partial => 'provisioning', :locals => { :templates => templates }
  end

  def preview_host_collection
    scope = Template.descendants.detect { |klass| klass.name == params[:scope] } || Template
    @hosts = scope.preview_host_collection.where("name LIKE :name", :name => "%#{params['q']}%").limit(10).pluck(:id, :name).map { |id, name| {:id => id, :name => name} }
    respond_to do |format|
      format.json { render :json => @hosts }
    end
  end

  private

  def resource_base
    @resource_base ||= Host.authorized(current_permission, Host)
  end

  define_action_permission [
    'clone', 'externalNodes', 'overview', 'bmc', 'vm', 'runtime', 'resources', 'templates', 'nics',
    'pxe_config', 'active', 'errors', 'out_of_sync', 'pending', 'disabled', 'get_power_state', 'preview_host_collection', 'build_errors'
  ], :view
  define_action_permission [
    'setBuild', 'cancelBuild', 'multiple_build', 'submit_multiple_build', 'review_before_build',
    'rebuild_config', 'submit_rebuild_config'
  ], :build
  define_action_permission 'power', :power
  define_action_permission 'ipmi_boot', :ipmi_boot
  define_action_permission 'console', :console
  define_action_permission [
    'toggle_manage', 'multiple_parameters', 'update_multiple_parameters',
    'select_multiple_hostgroup', 'update_multiple_hostgroup',
    'multiple_disable', 'submit_multiple_disable',
    'multiple_enable', 'submit_multiple_enable',
    'update_multiple_organization', 'select_multiple_organization',
    'update_multiple_location', 'select_multiple_location',
    'disassociate', 'update_multiple_disassociate', 'multiple_disassociate',
    'select_multiple_owner', 'update_multiple_owner', 'forget_status',
    'select_multiple_power_state', 'update_multiple_power_state', 'random_name'
  ], :edit
  define_action_permission ['multiple_destroy', 'submit_multiple_destroy'], :destroy

  def refresh_host
    @host = Host::Base.authorized(:view_hosts, Host).find_by_id(params[:host_id] || params.dig(:host, :id))
    @host ||= Host.new(host_params)

    unless @host.is_a?(Host::Managed)
      @host      = @host.becomes(Host::Managed)
      @host.type = "Host::Managed"
    end
    @host.attributes = host_params unless @host.new_record?

    @host.lookup_values.each(&:validate_value)
    @host
  end

  def set_host_type
    return unless params[:host] && params[:host][:type]
    type = params[:host].delete(:type) # important, otherwise mass assignment will save the type.
    if type.constantize.new.is_a?(Host::Base)
      @host      = @host.becomes(type.constantize)
      @host.type = type
    else
      error _("invalid type: %s requested") % type
      render :unprocessable_entity
    end
  rescue => e
    Foreman::Logging.exception("Something went wrong while changing host type", e)
    error _("Something went wrong while changing host type - %s") % e
  end

  # overwrite application_controller
  def find_resource
    if (id = params[:id]).blank?
      not_found
      return false
    end
    @host = resource_base.friendly.find(id)
    @host ||= resource_base.find_by_mac params[:host][:mac].to_s if params[:host] && params[:host][:mac]

    unless @host
      not_found
      return(false)
    end

    @host
  end

  def multiple_with_filter?
    params.key?(:search)
  end

  def find_multiple
    # Lets search by name or id and make sure one of them exists first
    if params.key?(:host_names) || params.key?(:host_ids) || multiple_with_filter?
      @hosts = resource_base.search_for(params[:search]) if multiple_with_filter?
      @hosts ||= resource_base.merge(Host.where(id: params[:host_ids]).or(Host.where(name: params[:host_names])))
      if @hosts.empty?
        error _('No hosts were found with that id, name or query filter')
        redirect_to(hosts_path)
        return false
      end
    else
      error _('No hosts selected')
      redirect_to(hosts_path)
      return false
    end

    @hosts
  rescue => error
    message = _("Something went wrong while selecting hosts - %s") % error
    error(message)
    Foreman::Logging.exception(message, error)
    redirect_to hosts_path
    false
  end

  def toggle_hostmode(mode = true)
    # keep all the ones that were not disabled for notification.
    missed_hosts = @hosts.select { |host| !host.update_attribute(:enabled, mode) }
    action = mode ? "enabled" : "disabled"

    if missed_hosts.empty?
      success _("%s selected hosts") % action.capitalize
    else
      error _("The following hosts were not %{action}: %{missed_hosts}") % { :action => action, :missed_hosts => missed_hosts.map(&:name).to_sentence }
    end
    redirect_to(hosts_path)
  end

  # this is required for template generation (such as pxelinux) which is not done via a web request
  def forward_url_options(host = @host)
    host.url_options = url_options if @host.respond_to?(:url_options)
  end

  def merge_search_filter(filter)
    if params[:search].empty?
      params[:search] = filter
    else
      params[:search] += " and #{filter}"
    end
  end

  # if a save failed and the only reason was network conflicts then flag this so that the view
  # is rendered differently and the next save operation will be forced
  def offer_to_overwrite_conflicts
    @host.overwrite = "true" if @host.errors.any? && @host.errors.are_all_conflicts?
  end

  def validate_power_action
    if params[:power].blank? || (action = params[:power][:action]).blank? ||
        !PowerManager::REAL_ACTIONS.include?(action)
      error _('No or invalid power state selected!')
      redirect_to(select_multiple_power_state_hosts_path)
      false
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
        success _('The %{proxy_type} proxy of the selected hosts was cleared') % {:proxy_type => proxy_type}
      end
    else
      error n_("The %{proxy_type} proxy could not be set for host: %{host_names}.",
        "The %{proxy_type} puppet ca proxy could not be set for hosts: %{host_names}",
        failed_hosts.count) % {:proxy_type => proxy_type, :host_names => failed_hosts.map { |h, err| "#{h} (#{err})" }.to_sentence}
    end
    redirect_back_or_to hosts_path
  end

  def find_templates
    find_resource
    @templates = TemplateKind.order(:name).map do |kind|
      @host.provisioning_template(:kind => kind.name)
    end.compact
    raise Foreman::Exception.new(N_("No templates found")) if @templates.empty?
  end

  def host_attributes_for_templates(host)
    # This method wants to only get the attributes applicable to the current
    # kind of host. For example 'is_owned_by', even if it's in host_params,
    # should be ignored by Host::Discovered or any other Host class that does
    # not have that attribute
    host_attributes = host.class.attribute_names.dup
    if host_params["compute_attributes"].present?
      host_attributes << 'compute_attributes'
    end
    host_params.select do |k, v|
      host_attributes.include?(k) && !k.end_with?('_ids')
    end.except(:host_parameters_attributes)
  end

  def csv_columns
    [:name, :operatingsystem, :environment, :compute_resource_or_model, :hostgroup, :last_report]
  end

  def origin_intervals_query(compare_with)
    reported_origin_interval_settings.map do |origin, interval|
      "(origin = #{origin} and last_report #{compare_with}  \"#{interval + Setting[:outofsync_interval]} minutes ago\")"
    end
  end

  def reported_origin_interval_settings
    Hash[Report.origins.map do |origin|
      [origin, Setting[:"#{origin.downcase}_interval"].to_i]
    end]
  end

  def redirection_url_on_host_deletion
    default_redirection = { :success_redirect => hosts_path }
    return default_redirection unless session["redirect_to_url_#{controller_name}"]
    path_hash = main_app.routes.recognize_path(session["redirect_to_url_#{controller_name}"])
    return default_redirection if (path_hash.nil? || (path_hash && path_hash[:action] != 'index'))
    { :success_redirect => saved_redirect_url_or(send("#{controller_name}_url")) }
  end
end
