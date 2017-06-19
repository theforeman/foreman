class HostsController < ApplicationController
  define_callbacks :set_class_variables

  include Foreman::Controller::ActionPermissionDsl
  include ScopesPerAction
  include Foreman::Controller::HostDetails
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::TaxonomyMultiple
  include Foreman::Controller::SmartProxyAuth
  include Foreman::Controller::Parameters::Host
  include Foreman::Controller::Puppet::HostsControllerExtensions
  include Foreman::Controller::CsvResponder

  SEARCHABLE_ACTIONS= %w[index active errors out_of_sync pending disabled ]
  AJAX_REQUESTS=%w{compute_resource_selected current_parameters process_hostgroup process_taxonomy review_before_build scheduler_hint_selected}
  BOOT_DEVICES={ :disk => N_('Disk'), :cdrom => N_('CDROM'), :pxe => N_('PXE'), :bios => N_('BIOS') }
  MULTIPLE_ACTIONS = %w(multiple_parameters update_multiple_parameters select_multiple_hostgroup
                        update_multiple_hostgroup
                        multiple_destroy submit_multiple_destroy multiple_build
                        submit_multiple_build multiple_disable submit_multiple_disable
                        multiple_enable submit_multiple_enable
                        multiple_disassociate update_multiple_disassociate
                        rebuild_config submit_rebuild_config select_multiple_owner update_multiple_owner
                        select_multiple_power_state update_multiple_power_state)

  HOST_POWER = {
    :on =>  { :state => 'on', :title => N_('On') },
    :off => { :state => 'off', :title => N_('Off') },
    :na =>  { :state => 'na', :title => N_('N/A') }
  }.freeze

  before_action :ajax_request, :only => AJAX_REQUESTS + [:get_power_state]
  before_action :find_resource, :only => [:show, :clone, :edit, :update, :destroy, :puppetrun, :review_before_build,
                                          :setBuild, :cancelBuild, :power, :get_power_state, :overview, :bmc, :vm,
                                          :runtime, :resources, :nics, :ipmi_boot, :console,
                                          :toggle_manage, :pxe_config, :storeconfig_klasses, :disassociate]

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
        @hosts = search.includes(included_associations).paginate(:page => params[:page])
        # SQL optimizations queries
        @last_report_ids = ConfigReport.where(:host_id => @hosts.map(&:id)).group(:host_id).maximum(:id)
        @last_reports = ConfigReport.where(:id => @last_report_ids.values)
        # rendering index page for non index page requests (out of sync hosts etc)
        @hostgroup_authorizer = Authorizer.new(User.current, :collection => @hosts.map(&:hostgroup_id).compact.uniq)
        render :index if title && (@title = title)
      end
      format.csv do
        @hosts = search.includes(included_associations - [:host_statuses, :token, :compute_resource])
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
      format.yaml { render :text => @host.info.to_yaml }
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

      if @host.update_attributes(attributes)
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
      process_success :success_redirect => hosts_path
    else
      process_error
    end
  end

  # form AJAX methods
  def random_name
    render :json => { :name => NameGenerator.new.next_random_name }
  rescue ActionView::Template::Error => exception
    process_ajax_error exception, 'generate random name'
  end

  def compute_resource_selected
    return not_found unless (params[:host] && (id=params[:host][:compute_resource_id]))
    Taxonomy.as_taxonomy @organization, @location do
      compute_profile_id = params[:host][:compute_profile_id] || Hostgroup.find_by_id(params[:host][:hostgroup_id]).try(:inherited_compute_profile_id)
      compute_resource = ComputeResource.authorized(:view_compute_resources).find_by_id(id)
      render :partial => "compute", :locals => { :compute_resource => compute_resource,
                                                 :vm_attrs         => compute_resource.compute_profile_attributes_for(compute_profile_id) }
    end
  rescue ActionView::Template::Error => exception
    process_ajax_error exception, 'render compute resource template'
  end

  def scheduler_hint_selected
    return not_found unless (params[:host])
    @host = Host.new(host_params)
    Taxonomy.as_taxonomy @organization, @location do
      render :partial => "compute_resources_vms/form/scheduler_hint_filters"
    end
  end

  def interfaces
    @host = Host.new host_params
    @host.apply_compute_profile(InterfaceMerge.new)

    render :partial => "interfaces_tab"
  end

  def current_parameters
    Taxonomy.as_taxonomy @organization, @location do
      render :partial => "common_parameters/inherited_parameters", :locals => {:inherited_parameters => refresh_host.host_inherited_params(true), :parameters => refresh_host.host_parameters}
    end
  end

  def puppetclass_parameters
    Taxonomy.as_taxonomy @organization, @location do
      render :partial => "puppetclasses/classes_parameters", :locals => { :obj => refresh_host}
    end
  end

  #returns a yaml file ready to use for puppet external nodes script
  #expected a fqdn parameter to provide hostname to lookup
  #see example script in extras directory
  #will return HTML error codes upon failure

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
        host_info_yaml = @host.info.to_yaml(:line_width => -1)
        format.html { render :text => "<pre>#{ERB::Util.html_escape(host_info_yaml)}</pre>" }
        format.yml { render :text => host_info_yaml }
      end
    rescue => e
      Foreman::Logging.exception("Failed to generate external nodes for #{@host}", e)
      render :text => _('Unable to generate output, Check log files'),
             :status => :precondition_failed
    end
  end

  def puppetrun
    return deny_access unless Setting[:puppetrun]
    if @host.puppetrun!
      notice _("Successfully executed, check log files for more details")
    else
      error @host.errors[:base].to_sentence
    end
    redirect_to host_path(@host)
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
          process_success :success_msg => message % (@host), :success_redirect => :back
        rescue => error
          message = _('Failed to reboot %s.') % @host
          warning(message)
          Foreman::Logging.exception(message, error)
          process_success :success_msg => _("Enabled %s for rebuild on next boot") % (@host), :success_redirect => :back
        end
      else
        process_success :success_msg => _("Enabled %s for rebuild on next boot") % (@host), :success_redirect => :back
      end
    else
      process_error :redirect => :back, :error_msg => _("Failed to enable %{host} for installation: %{errors}") % { :host => @host, :errors => @host.errors.full_messages }
    end
  end

  def cancelBuild
    if @host.built(false)
      process_success :success_msg =>  _("Canceled pending build for %s") % (@host.name), :success_redirect => :back
    else
      process_error :redirect => :back, :error_msg => _("Failed to cancel pending build for %{hostname} with the following errors: %{errors}") % {:hostname => @host.name, :errors => @host.errors.full_messages.join(', ')}
    end
  end

  def power
    return invalid_request unless PowerManager::REAL_ACTIONS.include?(params[:power_action])
    @host.power.send(params[:power_action].to_sym)
    process_success :success_redirect => :back, :success_msg => _("%{host} is about to %{action}") % { :host => @host, :action => _(params[:power_action].downcase) }
  rescue => e
    process_error :redirect => :back, :error_msg => _("Failed to %{action} %{host}: %{e}") % { :action => _(params[:power_action]), :host => @host, :e => e }
  end

  def get_power_state
    result = {:id => @host.id}.merge(host_power_state(:na))
    if @host.supports_power?
      result = host_power_ping result
    else
      result[:statusText] = _('Power operations are not enabled on this host.')
    end

    render :json => result
  rescue => e
    Foreman::Logging.exception("Failed to fetch power status", e)
    result.merge!(host_power_state(:na))
    result[:statusText] = _("Failed to fetch power status: %s") % e
    render :json => result
  end

  def overview
    render :partial => 'overview', :locals => { :host => @host }
  rescue ActionView::Template::Error => exception
    process_ajax_error exception, 'fetch overview information'
  end

  def bmc
    render :partial => 'bmc', :locals => { :host => @host }
  rescue ActionView::Template::Error => exception
    process_ajax_error exception, 'fetch bmc information'
  end

  def vm
    @vm = @host.compute_resource.find_vm_by_uuid(@host.uuid)
    @compute_resource = @host.compute_resource
    render :partial => "compute_resources_vms/details"
  rescue ActionView::Template::Error => exception
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
    @encrypt = Setting[:websockets_encrypt]
    render case @console[:type]
             when 'spice'
               "hosts/console/spice"
             when 'vnc'
               "hosts/console/vnc"
             else
               "hosts/console/log"
           end
  rescue => e
    Foreman::Logging.exception("Failed to set console", e)
    process_error :redirect => :back, :error_msg => _("Failed to set console: %s") % (e)
  end

  def toggle_manage
    if @host.toggle! :managed
      if @host.managed
        @host.suggest_default_pxe_loader
        msg = _("Foreman now manages the build cycle for %s") % (@host.name)
      else
        msg = _("Foreman now no longer manages the build cycle for %s") % (@host.name)
      end
      process_success :success_msg => msg, :success_redirect => :back
    else
      process_error :error_msg => _("Failed to modify the build cycle for %s") % @host.name, :redirect => :back
    end
  end

  def disassociate
    if @host.compute?
      @host.disassociate!
      process_success :success_msg => _("%s has been disassociated from VM") % (@host.name), :success_redirect => :back
    else
      process_error :error_msg => _("Host %s is not associated with a VM") % @host.name, :redirect => :back
    end
  end

  def pxe_config
    redirect_to(:controller => "unattended", :action => 'host_template', :kind => "pxe_#{@host.operatingsystem.pxe_type}_config", :host_id => @host) if @host
  end

  def storeconfig_klasses
  end

  # multiple host selection methods

  def multiple_parameters
    @parameters = HostParameter.where(:reference_id => @hosts).select("distinct name")
  end

  def update_multiple_parameters
    if params[:name].empty?
      notice _("No parameters were allocated to the selected hosts, can't mass assign")
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
      notice _('Updated all hosts!')
      redirect_to(hosts_path)
      return
    else
      notice _("%s Parameters updated, see below for more information") % (counter)
    end
  end

  def select_multiple_hostgroup
  end

  def update_multiple_hostgroup
    # simple validations
    unless (id=params["hostgroup"]["id"])
      error _('No host group selected!')
      redirect_to(select_multiple_hostgroup_hosts_path)
      return
    end
    hg = Hostgroup.find_by_id(id)
    #update the hosts
    @hosts.each do |host|
      host.hostgroup=hg
      host.save(:validate => false)
    end

    notice _('Updated hosts: changed host group')
    # We prefer to go back as this does not lose the current search
    redirect_back_or_to hosts_path
  end

  def select_multiple_owner
  end

  def update_multiple_owner
    # simple validations
    if (params[:owner].nil?) || (id=params["owner"]["id"]).nil?
      error _('No owner selected!')
      redirect_to(select_multiple_owner_hosts_path)
      return
    end

    #update the hosts
    @hosts.each do |host|
      host.is_owned_by = id
      host.save(:validate => false)
    end

    notice _('Updated hosts: changed owner')
    redirect_back_or_to hosts_path
  end

  def select_multiple_power_state
  end

  def update_multiple_power_state
    action = params[:power][:action]
    @hosts.each do |host|
      begin
        host.power.send(action.to_sym) if host.supports_power?
      rescue => error
        message = _('Failed to set power state for %s.') % host
        Foreman::Logging.exception(message, error)
      end
    end

    notice _('The power state of the selected hosts will be set to %s') % _(action)
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
      notice _('Configuration successfully rebuilt')
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
        notice _("The selected hosts were enabled for reboot and rebuild")
      else
        notice _("The selected hosts will execute a build operation on next reboot")
      end
    else
      error _("The following hosts failed the build operation: %s") % missed_hosts.map(&:name).to_sentence
    end
    redirect_to(hosts_path)
  end

  def submit_multiple_destroy
    # keep all the ones that were not deleted for notification.
    missed_hosts = @hosts.select {|host| !host.destroy}
    if missed_hosts.empty?
      notice _("Destroyed selected hosts")
    else
      error _("The following hosts were not deleted: %s") % missed_hosts.map(&:name).to_sentence
    end
    redirect_to(hosts_path)
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
    notice _('Updated hosts: Disassociated from VM')
    redirect_back_or_to hosts_path
  end

  def errors
    merge_search_filter("last_report > \"#{Setting[:puppet_interval] + Setting[:outofsync_interval]} minutes ago\" and (status.failed > 0 or status.failed_restarts > 0)")
    index _("Hosts with errors")
  end

  def active
    merge_search_filter("last_report > \"#{Setting[:puppet_interval] + Setting[:outofsync_interval]} minutes ago\" and (status.applied > 0 or status.restarted > 0)")
    index _("Active Hosts")
  end

  def pending
    merge_search_filter("last_report > \"#{Setting[:puppet_interval] + Setting[:outofsync_interval]} minutes ago\" and (status.pending > 0)")
    index _("Pending Hosts")
  end

  def out_of_sync
    merge_search_filter("last_report < \"#{Setting[:puppet_interval] + Setting[:outofsync_interval]} minutes ago\" and status.enabled = true")
    index _("Hosts which didn't run puppet in the last %s") % (view_context.time_ago_in_words((Setting[:puppet_interval]+Setting[:outofsync_interval]).minutes.ago))
  end

  def disabled
    merge_search_filter("status.enabled = false")
    index _("Hosts with notifications disabled")
  end

  def process_hostgroup
    @hostgroup = Hostgroup.find(params[:host][:hostgroup_id]) if params[:host][:hostgroup_id].to_i > 0
    return head(:not_found) unless @hostgroup

    @host = if params[:host][:id]
              host = Host::Base.authorized(:view_hosts).find(params[:host][:id])
              host = host.becomes Host::Managed
              host.attributes = host.apply_inherited_attributes(host_params)
              host
            else
              Host.new(host_params)
            end
    @host.set_hostgroup_defaults true
    @host.set_compute_attributes unless params[:host][:compute_profile_id]
    set_class_variables(@host)
    render :partial => "form"
  end

  def process_taxonomy
    return head(:not_found) unless @location || @organization
    @host = Host.new(host_params)
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
    host.attributes = host_attributes_for_templates(host)
    templates = host.available_template_kinds(params[:provisioning])
    return not_found if templates.empty?
    render :partial => 'provisioning', :locals => { :templates => templates }
  end

  def preview_host_collection
    scope = Template.descendants.detect { |klass| klass.name == params[:scope] } || Template
    @hosts = scope.preview_host_collection.where("name LIKE :name", :name => "%#{params['q']}%").limit(10).pluck(:id, :name).map {|id, name| {:id => id, :name => name}}
    respond_to do |format|
     format.json { render :json => @hosts }
    end
  end

  private

  def resource_base
    @resource_base ||= Host.authorized(current_permission, Host)
  end

  define_action_permission %w[
    clone externalNodes overview bmc vm runtime resources templates nics
    pxe_config storeconfig_klasses active errors out_of_sync pending disabled get_power_state preview_host_collection], :view
  define_action_permission %w[
    setBuild cancelBuild multiple_build submit_multiple_build review_before_build
    rebuild_config submit_rebuild_config], :build
  define_action_permission 'power', :power
  define_action_permission 'ipmi_boot', :ipmi_boot
  define_action_permission 'console', :console
  define_action_permission %w[
    toggle_manage multiple_parameters update_multiple_parameters
    select_multiple_hostgroup update_multiple_hostgroup
    multiple_disable submit_multiple_disable
    multiple_enable submit_multiple_enable
    update_multiple_organization select_multiple_organization
    update_multiple_location select_multiple_location
    disassociate update_multiple_disassociate multiple_disassociate
    select_multiple_owner update_multiple_owner
    select_multiple_power_state update_multiple_power_state random_name], :edit
  define_action_permission %w[multiple_destroy submit_multiple_destroy], :destroy

  def refresh_host
    @host = Host::Base.authorized(:view_hosts, Host).find_by_id(params['host_id'])
    if @host
      unless @host.is_a?(Host::Managed)
        @host      = @host.becomes(Host::Managed)
        @host.type = "Host::Managed"
      end
      @host.attributes = host_params
    else
      @host ||= Host::Managed.new(host_params)
    end

    @host
  end

  def set_host_type
    return unless params[:host] && params[:host][:type]
    type = params[:host].delete(:type) #important, otherwise mass assignment will save the type.
    if type.constantize.new.is_a?(Host::Base)
      @host      = @host.becomes(type.constantize)
      @host.type = type
    else
      error _("invalid type: %s requested") % (type)
      render :unprocessable_entity
    end
  rescue => e
    Foreman::Logging.exception("Something went wrong while changing host type", e)
    error _("Something went wrong while changing host type - %s") % (e)
  end

  def taxonomy_scope
    if params[:host]
      @organization = Organization.find_by_id(params[:host][:organization_id])
      @location = Location.find_by_id(params[:host][:location_id])
    end

    if @host
      @organization ||= @host.organization
      @location     ||= @host.location
    end

    @organization ||= Organization.find_by_id(params[:organization_id]) if params[:organization_id]
    @location     ||= Location.find_by_id(params[:location_id])         if params[:location_id]

    @organization ||= Organization.current if SETTINGS[:organizations_enabled]
    @location     ||= Location.current     if SETTINGS[:locations_enabled]
  end

  # overwrite application_controller
  def find_resource
    if (id = params[:id]).blank?
      not_found
      return false
    end
    @host   = resource_base.friendly.find(id)
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

  def load_vars_for_ajax
    return unless @host

    taxonomy_scope
    if @host.compute_resource_id && params[:host] && params[:host][:compute_attributes]
      @host.compute_attributes = params[:host][:compute_attributes]
    end

    set_class_variables(@host)
  end

  def find_multiple
  # Lets search by name or id and make sure one of them exists first
    if params.key?(:host_names) || params.key?(:host_ids) || multiple_with_filter?
      @hosts = resource_base.search_for(params[:search]) if multiple_with_filter?
      @hosts ||= resource_base.where("hosts.id IN (?) or hosts.name IN (?)", params[:host_ids], params[:host_names])
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

    return @hosts
  rescue => error
    message = _("Something went wrong while selecting hosts - %s") % error
    error(message)
    Foreman::Logging.exception(message, error)
    redirect_to hosts_path
    return false
  end

  def toggle_hostmode(mode = true)
    # keep all the ones that were not disabled for notification.
    missed_hosts = @hosts.select { |host| !host.update_attribute(:enabled, mode) }
    action = mode ? "enabled" : "disabled"

    if missed_hosts.empty?
      notice _("%s selected hosts") % (action.capitalize)
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
    if params[:power].blank? || (action=params[:power][:action]).blank? ||
        !PowerManager::REAL_ACTIONS.include?(action)
      error _('No or invalid power state selected!')
      redirect_to(select_multiple_power_state_hosts_path)
      return false
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

    if !proxy_id.blank? && !SmartProxy.find_by_id(proxy_id)
      error _('Invalid proxy selected!')
      redirect_to(redirect_path)
      return false
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
        notice _('The %{proxy_type} proxy of the selected hosts was set to %{proxy_name}') % {:proxy_name => proxy.name, :proxy_type => proxy_type}
      else
        notice _('The %{proxy_type} proxy of the selected hosts was cleared') % {:proxy_type => proxy_type}
      end
    else
      error n_("The %{proxy_type} proxy could not be set for host: %{host_names}.",
               "The %{proxy_type} puppet ca proxy could not be set for hosts: %{host_names}",
               failed_hosts.count) % {:proxy_type => proxy_type, :host_names => failed_hosts.map {|h, err| "#{h} (#{err})"}.to_sentence}
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

  def set_class_variables(host)
    run_callbacks :set_class_variables do
      @architecture    = host.architecture
      @operatingsystem = host.operatingsystem
      @domain          = host.domain
      @subnet          = host.subnet
      @compute_profile = host.compute_profile
      @realm           = host.realm
      @hostgroup       = host.hostgroup
    end
  end

  def host_power_ping(result)
    timeout = 3
    Timeout.timeout(timeout) do
      result.merge!(host_power_state(@host.supports_power_and_running? ? :on : :off))
    end
    result
  rescue Timeout::Error
    logger.debug("Failed to retrieve power status for #{@host} within #{timeout} seconds.")
    result[:statusText] = n_("Failed to retrieve power status for %{host} within %{timeout} second.",
                             "Failed to retrieve power status for %{host} within %{timeout} seconds.", timeout) %
                            {:host => @host, :timeout => timeout}
    result
  end

  def host_power_state(key)
    HOST_POWER[key].merge(:title => _(HOST_POWER[key][:title]))
  end

  def host_attributes_for_templates(host)
    # This method wants to only get the attributes applicable to the current
    # kind of host. For example 'is_owned_by', even if it's in host_params,
    # should be ignored by Host::Discovered or any other Host class that does
    # not have that attribute
    host_attributes = host.class.attribute_names
    host_params.select do |k,v|
       host_attributes.include?(k) && !k.end_with?('_ids')
    end.except(:host_parameters_attributes)
  end

  def csv_columns
    [:name, :operatingsystem, :environment, :model, :hostgroup, :last_report]
  end
end
