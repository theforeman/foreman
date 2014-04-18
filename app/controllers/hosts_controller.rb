class HostsController < ApplicationController
  include Foreman::Controller::HostDetails
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::TaxonomyMultiple
  include Foreman::Controller::SmartProxyAuth

  PUPPETMASTER_ACTIONS=[ :externalNodes, :lookup ]
  SEARCHABLE_ACTIONS= %w[index active errors out_of_sync pending disabled ]
  AJAX_REQUESTS=%w{compute_resource_selected hostgroup_or_environment_selected current_parameters puppetclass_parameters process_hostgroup process_taxonomy}
  BOOT_DEVICES={ :disk => N_('Disk'), :cdrom => N_('CDROM'), :pxe => N_('PXE'), :bios => N_('BIOS') }
  MULTIPLE_ACTIONS = %w(multiple_parameters update_multiple_parameters  select_multiple_hostgroup
                        update_multiple_hostgroup select_multiple_environment update_multiple_environment
                        multiple_destroy submit_multiple_destroy multiple_build
                        submit_multiple_build multiple_disable submit_multiple_disable
                        multiple_enable submit_multiple_enable multiple_puppetrun
                        update_multiple_puppetrun multiple_disassociate update_multiple_disassociate)

  add_puppetmaster_filters PUPPETMASTER_ACTIONS
  before_filter :ajax_request, :only => AJAX_REQUESTS
  before_filter :find_by_name, :only => [:show, :clone, :edit, :update, :destroy, :puppetrun,
                                         :setBuild, :cancelBuild, :power, :bmc, :vm, :ipmi_boot,
                                         :console, :toggle_manage, :pxe_config,
                                         :storeconfig_klasses, :disassociate]
  before_filter :taxonomy_scope, :only => [:new, :edit] + AJAX_REQUESTS
  before_filter :set_host_type, :only => [:update]
  before_filter :find_multiple, :only => MULTIPLE_ACTIONS
  helper :hosts, :reports

  def index (title = nil)
    begin
      search = resource_base.search_for(params[:search], :order => params[:order])
    rescue => e
      error e.to_s
      search = resource_base.search_for ''
    end
    respond_to do |format|
      format.html do
        @hosts = search.includes(included_associations).paginate(:page => params[:page])
        # SQL optimizations queries
        @last_reports = Report.where(:host_id => @hosts.map(&:id)).group(:host_id).maximum(:id)
        # rendering index page for non index page requests (out of sync hosts etc)
        @hostgroup_authorizer = Authorizer.new(User.current, :collection => @hosts.map(&:hostgroup_id).compact.uniq)
        render :index if title and (@title = title)
      end
      format.yaml do
        render :text => if params["rundeck"]
          result = {}
          search.includes(included_associations).each{|h| result.update(h.rundeck)}
          result
        else
          search.all(:select => "hosts.name").map(&:name)
        end.to_yaml
      end
      format.json
    end
  end

  def show
    respond_to do |format|
      format.html {
        # filter graph time range
        @range = (params["range"].empty? ? 7 : params["range"].to_i)

        # summary report text
        @report_summary = Report.summarise(@range.days.ago, @host)
      }
      format.yaml { render :text => params["rundeck"].nil? ? @host.info.to_yaml : @host.rundeck.to_yaml }
      format.json
    end
  end

  def new
    @host = Host.new :managed => true
  end

  # Clone the host
  def clone
    @clone_host = @host
    new = @host.dup
    new.name = nil
    new.mac = nil
    new.ip = nil
    load_vars_for_ajax
    flash[:warning] = _("The marked fields will need reviewing")
    new.valid?
    @host = new
    render :action => :new
  end

  def create
    @host = Host.new(params[:host])
    @host.managed = true if (params[:host] && params[:host][:managed].nil?)
    forward_url_options
    if @host.save
      process_success :success_redirect => host_path(@host), :redirect_xhr => request.xhr?
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
      # remove from hash :root_pass and bmc :password if blank?
      params[:host].except!(:root_pass) if params[:host][:root_pass].blank?
      if @host.type == "Host::Managed" && params[:host][:interfaces_attributes]
        params[:host][:interfaces_attributes].each do |k, v|
          params[:host][:interfaces_attributes]["#{k}"].except!(:password) if params[:host][:interfaces_attributes]["#{k}"][:password].blank?
        end
      end
      if @host.update_attributes(params[:host])
        process_success :success_redirect => host_path(@host), :redirect_xhr => request.xhr?
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
      process_success
    else
      process_error
    end
  end

  # form AJAX methods
  def compute_resource_selected
    return not_found unless (params[:host] && (id=params[:host][:compute_resource_id]))
    Taxonomy.as_taxonomy @organization, @location do
      compute_profile_id = params[:host][:compute_profile_id] || Hostgroup.find_by_id(params[:host][:hostgroup_id]).try(:compute_profile_id)
      compute_resource = ComputeResource.authorized(:view_compute_resources).find_by_id(id)
      render :partial => "compute", :locals => { :compute_resource => compute_resource,
                                                 :vm_attrs         => compute_resource.compute_profile_attributes_for(compute_profile_id) }
    end
  end

  def hostgroup_or_environment_selected
    Taxonomy.as_taxonomy @organization, @location do
      if params['host']['environment_id'].present? || params['host']['hostgroup_id'].present?
        render :partial => 'puppetclasses/class_selection', :locals => {:obj => (refresh_host)}
      else
        logger.info "environment_id or hostgroup_id is required to render puppetclasses"
      end
    end
  end

  def current_parameters
    Taxonomy.as_taxonomy @organization, @location do
      render :partial => "common_parameters/inherited_parameters", :locals => {:inherited_parameters => refresh_host.host_inherited_params(true)}
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
    certname = params[:name]
    @host ||= resource_base.find_by_certname certname
    @host ||= resource_base.find_by_name certname
    not_found and return unless @host

    begin
      respond_to do |format|
        format.html { render :text => "<pre>#{@host.info.to_yaml}</pre>" }
        format.yml { render :text => @host.info.to_yaml }
      end
    rescue
      # failed
      logger.warn "Failed to generate external nodes for #{@host} with #{$!}"
      render :text => _('Unable to generate output, Check log files\n'), :status => 412 and return
    end
  end

  def puppetrun
    return deny_access unless Setting[:puppetrun]
    if @host.puppetrun!
      notice _("Successfully executed, check log files for more details")
    else
      error @host.errors[:base]
    end
    redirect_to host_path(@host)
  end

  def setBuild
    forward_url_options
    if @host.setBuild
      process_success :success_msg => _("Enabled %s for rebuild on next boot") % (@host), :success_redirect => :back
    else
      process_error :redirect => :back, :error_msg => _("Failed to enable %{host} for installation: %{errors}") % { :host => @host, :errors => @host.errors.full_messages }
    end
  end

  def cancelBuild
    if @host.built(false)
      process_success :success_msg =>  _("Canceled pending build for %s") % (@host.name), :success_redirect => :back
    else
      process_error :redirect => :back, :error_msg => _("Failed to cancel pending build for %s") % (@host.name)
    end
  end

  def power
    return invalid_request unless PowerManager::SUPPORTED_ACTIONS.include?(params[:power_action])
    @host.power.send(params[:power_action].to_sym)
    process_success :success_redirect => :back, :success_msg => _("%{host} is about to %{action}") % { :host => @host, :action => _(params[:power_action].downcase) }
  rescue => e
    process_error :redirect => :back, :error_msg => _("Failed to %{action} %{host}: %{e}") % { :action => _(params[:power_action]), :host => @host, :e => e }
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
    render case @console[:type]
             when 'spice'
               "hosts/console/spice"
             when 'vnc'
               "hosts/console/vnc"
             else
               "hosts/console/log"
           end
  rescue => e
    process_error :redirect => :back, :error_msg => _("Failed to set console: %s") % (e)
  end

  def toggle_manage
    if @host.toggle! :managed
      if @host.managed
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
    if @host.uuid.nil? && @host.compute_resource_id.nil?
      process_error :error_msg => _("Host %s is not associated with a VM") % @host.name, :redirect => :back
    else
      @host.uuid = nil
      @host.compute_resource_id = nil
      @host.save!(:validate => false) # don't want to trigger callbacks
      msg = _("%s has been disassociated from VM") % (@host.name)
      process_success :success_msg => msg, :success_redirect => :back
    end
  end

  def pxe_config
    redirect_to(:controller => "unattended", :action => "pxe_#{@host.operatingsystem.pxe_type}_config", :host_id => @host) if @host
  end

  def storeconfig_klasses
  end

  # multiple host selection methods

  def multiple_parameters
    @parameters = HostParameter.where(:reference_id => @hosts).select("distinct name")
  end

  def update_multiple_parameters
    if params[:name].empty?
      notice _("No parameters were allocated to the selected hosts, can't mass assign.")
      redirect_to hosts_path and return
    end

    @skipped_parameters = {}
    counter = 0
    @hosts.each do |host|
      skipped = []
      params[:name].each do |name, value|
        next if value.empty?
        if (host_param = host.host_parameters.find_by_name(name))
          counter += 1 if host_param.update_attribute(:value, value)
        else
          skipped << name
        end
        @skipped_parameters[host.name] = skipped unless skipped.empty?
      end
    end
    if @skipped_parameters.empty?
      notice _('Updated all hosts!')
      redirect_to(hosts_path) and return
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
      redirect_to(select_multiple_hostgroup_hosts_path) and return
    end
    hg = Hostgroup.find(id) rescue nil
    #update the hosts
    @hosts.each do |host|
      host.hostgroup=hg
      host.save(:validate => false)
    end

    notice _('Updated hosts: changed host group')
    # We prefer to go back as this does not lose the current search
    redirect_back_or_to hosts_path
  end

  def select_multiple_environment
  end

  def update_multiple_environment
    # simple validations
    if (params[:environment].nil?) or (id=params["environment"]["id"]).nil?
      error _('No environment selected!')
      redirect_to(select_multiple_environment_hosts_path) and return
    end

    ev = Environment.find(id) rescue nil

    #update the hosts
    @hosts.each do |host|
      host.environment = (id == 'inherit' && host.hostgroup.present? ) ? host.hostgroup.environment : ev
      host.save(:validate => false)
    end

    notice _('Updated hosts: changed environment')
    redirect_back_or_to hosts_path
  end

  def multiple_destroy
  end

  def multiple_build
  end

  def submit_multiple_build
    @hosts.delete_if do |host|
      forward_url_options(host)
      host.setBuild
    end

    missed_hosts = @hosts.map(&:name).join('<br/>')
    if @hosts.empty?
      notice _("The selected hosts will execute a build operation on next reboot")
    else
      error _("The following hosts failed the build operation: %s") % (missed_hosts)
    end
    redirect_to(hosts_path)
  end

  def submit_multiple_destroy
    # keep all the ones that were not deleted for notification.
    @hosts.delete_if {|host| host.destroy}

    missed_hosts = @hosts.map(&:name).join('<br/>')
    if @hosts.empty?
      notice _("Destroyed selected hosts")
    else
      error _("The following hosts were not deleted: %s") % (missed_hosts)
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

  def multiple_puppetrun
    deny_access unless Setting[:puppetrun]
  end

  def update_multiple_puppetrun
    return deny_access unless Setting[:puppetrun]
    if @hosts.map(&:puppetrun!).uniq == [true]
      notice _("Successfully executed, check reports and/or log files for more details")
    else
      error _("Some or all hosts execution failed, Please check log files for more information")
    end
    redirect_back_or_to hosts_path
  end

  def multiple_disassociate
  end

  def update_multiple_disassociate
    @hosts.each do |host|
      host.uuid = nil
      host.compute_resource_id = nil
      host.save(:validate => false)
    end
    notice _('Updated hosts: Disassociated from VM')
    redirect_back_or_to hosts_path
  end

  def errors
    merge_search_filter("last_report > \"#{Setting[:puppet_interval] + 5} minutes ago\" and (status.failed > 0 or status.failed_restarts > 0)")
    index _("Hosts with errors")
  end

  def active
    merge_search_filter("last_report > \"#{Setting[:puppet_interval] + 5} minutes ago\" and (status.applied > 0 or status.restarted > 0)")
    index _("Active Hosts")
  end

  def pending
    merge_search_filter("last_report > \"#{Setting[:puppet_interval] + 5} minutes ago\" and (status.pending > 0)")
    index _("Pending Hosts")
  end

  def out_of_sync
    merge_search_filter("last_report < \"#{Setting[:puppet_interval] + 5} minutes ago\" and status.enabled = true")
    index _("Hosts which didn't run puppet in the last %s") % (view_context.time_ago_in_words((Setting[:puppet_interval]+5).minutes.ago))
  end

  def disabled
    merge_search_filter("status.enabled = false")
    index _("Hosts with notifications disabled")
  end

  def process_hostgroup
    @hostgroup = Hostgroup.find(params[:host][:hostgroup_id]) if params[:host][:hostgroup_id].to_i > 0
    return head(:not_found) unless @hostgroup

    @architecture    = @hostgroup.architecture
    @operatingsystem = @hostgroup.operatingsystem
    @environment     = @hostgroup.environment
    @domain          = @hostgroup.domain
    @subnet          = @hostgroup.subnet
    @compute_profile = @hostgroup.compute_profile
    @realm           = @hostgroup.realm

    @host = if params[:host][:id]
      host = Host::Base.authorized(:view_hosts, Host).find(params[:host][:id])
      host = host.becomes Host::Managed
      host.attributes = params[:host]
      host
    else
      Host.new(params[:host])
    end
    @host.set_hostgroup_defaults
    render :partial => "form"

  end

  def process_taxonomy
    return head(:not_found) unless @location || @organization
    @host = Host.new(params[:host])
    # revert compute resource to "Bare Metal" (nil) if selected
    # compute resource is not included taxonomy
    Taxonomy.as_taxonomy @organization , @location do
      # if compute_resource_id is not in our scope, reset it to nil.
      @host.compute_resource_id = nil unless ComputeResource.exists?(@host.compute_resource_id)
    end
    render :partial => 'form'
  end

  def template_used
    host  = params[:host]
    kinds = if params[:provisioning] == 'image'
              cr     = ComputeResource.find_by_id(host[:compute_resource_id])
              images = cr.try(:images)
              if images.nil?
                [TemplateKind.find_by_name('finish')]
              else
                uuid       = host[:compute_attributes][cr.image_param_name]
                image_kind = images.find_by_uuid(uuid).try(:user_data) ? 'user_data' : 'finish'
                [TemplateKind.find_by_name(image_kind)]
              end
            else
              TemplateKind.all
            end

    templates = kinds.map do |kind|
      ConfigTemplate.find_template({:kind               => kind.name,
                                    :operatingsystem_id => host[:operatingsystem_id],
                                    :hostgroup_id       => host[:hostgroup_id],
                                    :environment_id     => host[:environment_id]
      })
    end.compact
    return not_found if templates.empty?
    render :partial => "provisioning", :locals => {:templates => templates}
  end

  private

  def resource_base
    @resource_base ||= Host.authorized(current_permission, Host)
  end

  def action_permission
    case params[:action]
      when 'clone', 'externalNodes', 'bmc', 'vm', 'pxe_config', 'storeconfig_klasses',
          'active', 'errors', 'out_of_sync', 'pending', 'disabled'
        :view
      when 'puppetrun', 'multiple_puppetrun', 'update_multiple_puppetrun'
        :puppetrun
      when 'setBuild', 'cancelBuild', 'multiple_build', 'submit_multiple_build'
        :build
      when 'power'
        :power
      when 'ipmi_boot'
        :ipmi_boot
      when 'console'
        :console
      when 'toggle_manage', 'multiple_parameters', 'update_multiple_parameters',
          'select_multiple_hostgroup', 'update_multiple_hostgroup', 'select_multiple_environment',
          'update_multiple_environment', 'multiple_disable', 'submit_multiple_disable',
          'multiple_enable', 'submit_multiple_enable',
          'update_multiple_organization', 'select_multiple_organization',
          'update_multiple_location', 'select_multiple_location',
          'disassociate', 'update_multiple_disassociate', 'multiple_disassociate'
        :edit
      when 'multiple_destroy', 'submit_multiple_destroy'
        :destroy
      else
        super
    end
  end

  def refresh_host
    @host = Host::Base.authorized(:view_hosts, Host).find_by_id(params['host_id'])
    if @host
      unless @host.kind_of?(Host::Managed)
        @host      = @host.becomes(Host::Managed)
        @host.type = "Host::Managed"
      end
      @host.attributes = params['host']
    else
      @host ||= Host::Managed.new(params['host'])
    end
    return @host
  end

  def set_host_type
    return unless params[:host] and params[:host][:type]
    type = params[:host].delete(:type) #important, otherwise mass assignment will save the type.
    if type.constantize.new.kind_of?(Host::Base)
      @host      = @host.becomes(type.constantize)
      @host.type = type
    else
      error _("invalid type: %s requested") % (type)
      render :unprocessable_entity
    end
  rescue => e
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

    if SETTINGS[:organizations_enabled]
      @organization ||= Organization.current
      @organization ||= Organization.my_organizations.first
    end
    if SETTINGS[:locations_enabled]
      @location ||= Location.current
      @location ||= Location.my_locations.first
    end
  end

  def find_by_name
    not_found and return false if (id = params[:id]).blank?
    # determine if we are searching for a numerical id or plain name

    if id =~ /^\d+$/
      @host = resource_base.find_by_id id.to_i
    else
      @host = resource_base.find_by_name id.downcase
      @host ||= resource_base.find_by_mac params[:host][:mac] if params[:host] && params[:host][:mac]
    end

    not_found and return(false) unless @host
    @host
  end

  def load_vars_for_ajax
    return unless @host

    taxonomy_scope
    @environment     = @host.environment
    @architecture    = @host.architecture
    @domain          = @host.domain
    @operatingsystem = @host.operatingsystem
    @medium          = @host.medium
    if @host.compute_resource_id && params[:host] && params[:host][:compute_attributes]
      @host.compute_attributes = params[:host][:compute_attributes]
    end
  end

  def find_multiple
  # Lets search by name or id and make sure one of them exists first
    if params[:host_names].present? or params[:host_ids].present?
      @hosts = resource_base.where("id IN (?) or name IN (?)", params[:host_ids], params[:host_names] )
      if @hosts.empty?
        error _('No hosts were found with that id or name')
        redirect_to(hosts_path) and return false
      end
    else
      error _('No hosts selected')
      redirect_to(hosts_path) and return false
    end

    return @hosts
  rescue => e
    error _("Something went wrong while selecting hosts - %s") % (e)
    logger.debug e.message
    logger.debug e.backtrace.join("\n")
    redirect_to hosts_path and return false
  end

  def toggle_hostmode mode=true
    # keep all the ones that were not disabled for notification.
    @hosts.delete_if { |host| host.update_attribute(:enabled, mode) }
    action = mode ? "enabled" : "disabled"

    missed_hosts       = @hosts.map(&:name).join('<br/>')
    if @hosts.empty?
      notice _("%s selected hosts") % (action.capitalize)
    else
      error _("The following hosts were not %{action}: %{missed_hosts}") % { :action => action, :missed_hosts => missed_hosts }
    end
    redirect_to(hosts_path)
  end

  # this is required for template generation (such as pxelinux) which is not done via a web request
  def forward_url_options(host = @host)
    host.url_options = url_options if @host.respond_to?(:url_options)
  end

  def merge_search_filter filter
    if params[:search].empty?
      params[:search] = filter
    else
      params[:search] += " and #{filter}"
    end
  end

  # if a save failed and the only reason was network conflicts then flag this so that the view
  # is rendered differently and the next save operation will be forced
  def offer_to_overwrite_conflicts
    @host.overwrite = "true" if @host.errors.any? and @host.errors.are_all_conflicts?
  end

end
