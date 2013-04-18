class HostsController < ApplicationController
  include Foreman::Controller::HostDetails
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::TaxonomyMultiple
  include Foreman::Controller::SmartProxyAuth

  PUPPETMASTER_ACTIONS=[ :externalNodes, :lookup ]
  SEARCHABLE_ACTIONS= %w[index active errors out_of_sync pending disabled ]
  AJAX_REQUESTS=%w{compute_resource_selected hostgroup_or_environment_selected current_parameters puppetclass_parameters}
  BOOT_DEVICES={ :disk => N_('Disk'), :cdrom => N_('CDROM'), :pxe => N_('PXE'), :bios => N_('BIOS') }

  add_puppetmaster_filters PUPPETMASTER_ACTIONS
  before_filter :ajax_request, :only => AJAX_REQUESTS
  before_filter :find_multiple, :only => [:update_multiple_parameters, :multiple_build,
    :select_multiple_hostgroup, :select_multiple_environment, :multiple_parameters, :multiple_destroy,
    :multiple_enable, :multiple_disable, :submit_multiple_disable, :submit_multiple_enable, :update_multiple_hostgroup,
    :update_multiple_environment, :submit_multiple_build, :submit_multiple_destroy, :update_multiple_puppetrun,
    :multiple_puppetrun]
  before_filter :find_by_name, :only => %w[show edit update destroy puppetrun setBuild cancelBuild
    storeconfig_klasses clone pxe_config toggle_manage power console bmc ipmi_boot]
  before_filter :taxonomy_scope, :only => [:hostgroup_or_environment_selected, :process_hostgroup]
  before_filter :set_host_type, :only => [:update]
  helper :hosts, :reports

  def index (title = nil)
    begin
      search = Host.my_hosts.search_for(params[:search],:order => params[:order])
    rescue => e
      error e.to_s
      search = Host.my_hosts.search_for ''
    end
    respond_to do |format|
      format.html do
        @hosts = search.includes(included_associations).paginate(:page => params[:page])
        # SQL optimizations queries
        @last_reports = Report.where(:host_id => @hosts.map(&:id)).group(:host_id).maximum(:id)
        # rendering index page for non index page requests (out of sync hosts etc)
        render :index if title and (@title = title)
      end
      # should you ever need more attributes just add to the :only array or specify :methods, :include, :except to the options hash
      format.json { render :json => search.includes(included_associations).to_json({:only => [:name, :id, :hostgroup_id, :operatingsystem_id]}) }

      format.yaml do
        render :text => if params["rundeck"]
          result = {}
          search.all(:include => included_associations).each{|h| result.update(h.rundeck)}
          result
        else
          search.all(:select => "hosts.name").map(&:name)
        end.to_yaml
      end
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
      format.json { render :json => @host.to_json({:methods => [:host_parameters], :include => :interfaces }) }
    end
  end

  def new
    @host = Host.new :managed => true
  end

  # Clone the host
  def clone
    new = @host.dup
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
      if @host.update_attributes(params[:host])
        process_success :success_redirect => host_path(@host), :redirect_xhr => request.xhr?
      else
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
    compute = ComputeResource.find(params[:compute_resource_id]) if params[:compute_resource_id].to_i > 0
    render :partial => "compute", :locals => {:compute_resource => compute} if compute
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
    render :partial => "common_parameters/inherited_parameters", :locals => {:inherited_parameters => refresh_host.host_inherited_params(true)}
  end

  def puppetclass_parameters
    render :partial => "puppetclasses/classes_parameters", :locals => { :obj => refresh_host}
  end

  #returns a yaml file ready to use for puppet external nodes script
  #expected a fqdn parameter to provide hostname to lookup
  #see example script in extras directory
  #will return HTML error codes upon failure

  def externalNodes
    certname = params[:name]
    @host ||= Host.find_by_certname certname
    @host ||= Host.find_by_name certname
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
    return invalid_request if params[:power_action].blank?
    @host.power.send(params[:power_action].to_sym)
    process_success :success_redirect => :back, :success_msg => _("%{host} is now %{state}") % { :host => @host, :state => _(@host.power.state) }
  rescue => e
    process_error :redirect => :back, :error_msg => _("Failed to %{action} %{host}: %{e}") % { :action => _(params[:power_action]), :host => @host, :e => e }
  end

  def bmc
    render :partial => 'bmc', :locals => { :host => @host }
  rescue => e
    #TODO: hack
    error = e.try(:original_exception).try(:response) || e.to_s
    logger.warn "failed to fetch bmc information: #{error}"
    logger.debug e.backtrace
    render :text => "Failure: #{error}"
  end

  def ipmi_boot
    device = params[:ipmi_device]
    begin
      @host.ipmi_boot(device)
      process_success :success_redirect => :back, :success_msg => _("%{host} now boots from %{device}") % { :host => @host.name, :device => _(BOOT_DEVICES[device.downcase.to_sym] || device) }
    rescue => e
      process_error :redirect => :back, :error_msg => _("Failed to configure %{host} to boot from %{device}: %{e}") % { :device => _(BOOT_DEVICES[device.downcase.to_sym] || device), :host => @host.name, :e => e }
    end
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

    organization = Organization.find(params[:host][:organization_id]) unless params[:host][:organization_id].empty?
    location = Location.find(params[:host][:location_id]) unless params[:host][:location_id].empty?

    @architecture    = @hostgroup.architecture
    @operatingsystem = @hostgroup.operatingsystem
    @environment     = @hostgroup.environment
    @domain          = @hostgroup.domain
    @subnet          = @hostgroup.subnet

    @host = Host.new(params[:host])
    @host.set_hostgroup_defaults

    Taxonomy.as_taxonomy organization, location do
      render :partial => "form"
    end

  end

  def process_taxonomy
    location = organization = nil
    organization = Organization.find(params[:host][:organization_id]) unless params[:host][:organization_id].empty?
    location = Location.find(params[:host][:location_id]) unless params[:host][:location_id].empty?
    return head(:not_found) unless location || organization

    @host = Host.new(params[:host])
    Taxonomy.as_taxonomy organization, location do
      render :partial => "form"
    end
  end


  def template_used
    kinds = params[:provisioning] == 'image' ? [TemplateKind.find_by_name('finish')] : TemplateKind.all
    templates = kinds.map do |kind|
      ConfigTemplate.find_template({:kind => kind.name, :operatingsystem_id => params[:operatingsystem_id],
                                   :hostgroup_id => params[:hostgroup_id], :environment_id => params[:environment_id]})
    end.compact
    return not_found if templates.empty?
    render :partial => "provisioning", :locals => {:templates => templates}
  end

  private

  def refresh_host
    @host = Host::Base.find_by_id(params['host_id'])
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
    @organization = params[:organization_id].blank? ? nil : Organization.find(Array.wrap(params[:organization_id]))
    @location     = params[:location_id].blank? ? nil : Location.find(Array.wrap(params[:location_id]))
  end

  def find_by_name
    # find host first, if we fail, do nothing
    params[:id].downcase! if params[:id].present?
    super
    return false unless @host
    deny_access and return unless User.current.admin? or Host.my_hosts.include?(@host)
  end

  def load_vars_for_ajax
    return unless @host

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
      @hosts = Host::Base.where("id IN (?) or name IN (?)", params[:host_ids], params[:host_names] )
      if @hosts.empty?
        error _('No hosts were found with that id or name')
        redirect_to(hosts_path) and return false
      end
    else
      error _('No hosts selected')
      redirect_to(hosts_path) and return false
    end

    rescue => e
      error _("Something went wrong while selecting hosts - %s") % (e)
      redirect_to hosts_path
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
