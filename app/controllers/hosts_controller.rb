class SystemsController < ApplicationController
  include Foreman::Controller::SystemDetails
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::TaxonomyMultiple
  include Foreman::Controller::SmartProxyAuth

  PUPPETMASTER_ACTIONS=[ :externalNodes, :lookup ]
  SEARCHABLE_ACTIONS= %w[index active errors out_of_sync pending disabled ]
  AJAX_REQUESTS=%w{compute_resource_selected system_group_or_environment_selected current_parameters puppetclass_parameters process_system_group process_taxonomy}
  BOOT_DEVICES={ :disk => N_('Disk'), :cdrom => N_('CDROM'), :pxe => N_('PXE'), :bios => N_('BIOS') }

  add_puppetmaster_filters PUPPETMASTER_ACTIONS
  before_filter :ajax_request, :only => AJAX_REQUESTS
  before_filter :find_multiple, :only => [:update_multiple_parameters, :multiple_build,
    :select_multiple_system_group, :select_multiple_environment, :multiple_parameters, :multiple_destroy,
    :multiple_enable, :multiple_disable, :submit_multiple_disable, :submit_multiple_enable, :update_multiple_system_group,
    :update_multiple_environment, :submit_multiple_build, :submit_multiple_destroy, :update_multiple_puppetrun,
    :multiple_puppetrun]
  before_filter :find_by_name, :only => %w[show edit update destroy puppetrun setBuild cancelBuild
    storeconfig_klasses clone pxe_config toggle_manage power console bmc ipmi_boot]
  before_filter :taxonomy_scope, :only => [:new, :edit] + AJAX_REQUESTS
  before_filter :set_system_type, :only => [:update]
  helper :systems, :reports

  def index (title = nil)
    begin
      search = System.my_systems.search_for(params[:search],:order => params[:order])
    rescue => e
      error e.to_s
      search = System.my_systems.search_for ''
    end
    respond_to do |format|
      format.html do
        @systems = search.includes(included_associations).paginate(:page => params[:page])
        # SQL optimizations queries
        @last_reports = Report.where(:system_id => @systems.map(&:id)).group(:system_id).maximum(:id)
        # rendering index page for non index page requests (out of sync systems etc)
        render :index if title and (@title = title)
      end
      format.yaml do
        render :text => if params["rundeck"]
          result = {}
          search.includes(included_associations).each{|h| result.update(h.rundeck)}
          result
        else
          search.all(:select => "systems.name").map(&:name)
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
        @report_summary = Report.summarise(@range.days.ago, @system)
      }
      format.yaml { render :text => params["rundeck"].nil? ? @system.info.to_yaml : @system.rundeck.to_yaml }
      format.json
    end
  end

  def new
    @system = System.new :managed => true
  end

  # Clone the system
  def clone
    @clone_system = @system
    new = @system.dup
    new.name = nil
    new.mac = nil
    new.ip = nil
    load_vars_for_ajax
    flash[:warning] = _("The marked fields will need reviewing")
    new.valid?
    @system = new
    render :action => :new
  end

  def create
    @system = System.new(params[:system])
    @system.managed = true if (params[:system] && params[:system][:managed].nil?)
    forward_url_options
    if @system.save
      process_success :success_redirect => system_path(@system), :redirect_xhr => request.xhr?
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
      params[:system].except!(:root_pass) if params[:system][:root_pass].blank?
      if @system.type == "System::Managed" && params[:system][:interfaces_attributes]
        params[:system][:interfaces_attributes].each do |k, v|
          params[:system][:interfaces_attributes]["#{k}"].except!(:password) if params[:system][:interfaces_attributes]["#{k}"][:password].blank?
        end
      end
      if @system.update_attributes(params[:system])
        process_success :success_redirect => system_path(@system), :redirect_xhr => request.xhr?
      else
        taxonomy_scope
        load_vars_for_ajax
        offer_to_overwrite_conflicts
        process_error
      end
    end
  end

  def destroy
    if @system.destroy
      process_success
    else
      process_error
    end
  end

  # form AJAX methods
  def compute_resource_selected
    return not_found unless (params[:system] && (id=params[:system][:compute_resource_id]))
    Taxonomy.as_taxonomy @organization, @location do
      render :partial => "compute", :locals => {:compute_resource => ComputeResource.find_by_id(id)}
    end
  end

  def system_group_or_environment_selected
    Taxonomy.as_taxonomy @organization, @location do
      if params['system']['environment_id'].present? || params['system']['system_group_id'].present?
        render :partial => 'puppetclasses/class_selection', :locals => {:obj => (refresh_system)}
      else
        logger.info "environment_id or system_group_id is required to render puppetclasses"
      end
    end
  end

  def current_parameters
    Taxonomy.as_taxonomy @organization, @location do
      render :partial => "common_parameters/inherited_parameters", :locals => {:inherited_parameters => refresh_system.system_inherited_params(true)}
    end
  end

  def puppetclass_parameters
    Taxonomy.as_taxonomy @organization, @location do
      render :partial => "puppetclasses/classes_parameters", :locals => { :obj => refresh_system}
    end
  end

  #returns a yaml file ready to use for puppet external nodes script
  #expected a fqdn parameter to provide systemname to lookup
  #see example script in extras directory
  #will return HTML error codes upon failure

  def externalNodes
    certname = params[:name]
    @system ||= System.find_by_certname certname
    @system ||= System.find_by_name certname
    not_found and return unless @system

    begin
      respond_to do |format|
        format.html { render :text => "<pre>#{@system.info.to_yaml}</pre>" }
        format.yml { render :text => @system.info.to_yaml }
      end
    rescue
      # failed
      logger.warn "Failed to generate external nodes for #{@system} with #{$!}"
      render :text => _('Unable to generate output, Check log files\n'), :status => 412 and return
    end
  end

  def puppetrun
    return deny_access unless Setting[:puppetrun]
    if @system.puppetrun!
      notice _("Successfully executed, check log files for more details")
    else
      error @system.errors[:base]
    end
    redirect_to system_path(@system)
  end

  def setBuild
    forward_url_options
    if @system.setBuild
      process_success :success_msg => _("Enabled %s for rebuild on next boot") % (@system), :success_redirect => :back
    else
      process_error :redirect => :back, :error_msg => _("Failed to enable %{system} for installation: %{errors}") % { :system => @system, :errors => @system.errors.full_messages }
    end
  end

  def cancelBuild
    if @system.built(false)
      process_success :success_msg =>  _("Canceled pending build for %s") % (@system.name), :success_redirect => :back
    else
      process_error :redirect => :back, :error_msg => _("Failed to cancel pending build for %s") % (@system.name)
    end
  end

  def power
    return invalid_request unless PowerManager::SUPPORTED_ACTIONS.include?(params[:power_action])
    @system.power.send(params[:power_action].to_sym)
    process_success :success_redirect => :back, :success_msg => _("%{system} is now %{state}") % { :system => @system, :state => _(@system.power.state) }
  rescue => e
    process_error :redirect => :back, :error_msg => _("Failed to %{action} %{system}: %{e}") % { :action => _(params[:power_action]), :system => @system, :e => e }
  end

  def bmc
    render :partial => 'bmc', :locals => { :system => @system }
  rescue ActionView::Template::Error => exception
    origin = exception.try(:original_exception)
    message = (origin || exception).message
    logger.warn "Failed to fetch bmc information: #{message}"
    logger.debug "Original exception backtrace:\n" + origin.backtrace.join("\n") if origin.present?
    logger.debug "Causing backtrace:\n" + exception.backtrace.join("\n")
    render :text => "Failure: #{message}"
  end

  def ipmi_boot
    device    = params[:ipmi_device]
    device_id = BOOT_DEVICES.stringify_keys[device.downcase] || device
    @system.ipmi_boot(device)
    process_success :success_redirect => :back, :success_msg => _("%{system} now boots from %{device}") % { :system => @system.name, :device => _(device_id) }
  rescue => e
    process_error :redirect => :back, :error_msg => _("Failed to configure %{system} to boot from %{device}: %{e}") % { :device => _(device_id), :system => @system.name, :e => e }
  end

  def console
    return unless @system.compute_resource
    @console = @system.compute_resource.console @system.uuid
    render case @console[:type]
             when 'spice'
               "systems/console/spice"
             when 'vnc'
               "systems/console/vnc"
             else
               "systems/console/log"
           end
  rescue => e
    process_error :redirect => :back, :error_msg => _("Failed to set console: %s") % (e)
  end

  def toggle_manage
    if @system.toggle! :managed
      if @system.managed
        msg = _("Foreman now manages the build cycle for %s") % (@system.name)
      else
        msg = _("Foreman now no longer manages the build cycle for %s") % (@system.name)
      end
      process_success :success_msg => msg, :success_redirect => :back
    else
      process_error :error_msg => _("Failed to modify the build cycle for %s") % @system.name, :redirect => :back
    end
  end

  def pxe_config
    redirect_to(:controller => "unattended", :action => "pxe_#{@system.operatingsystem.pxe_type}_config", :system_id => @system) if @system
  end

  def storeconfig_klasses
  end

  # multiple system selection methods

  def multiple_parameters
    @parameters = SystemParameter.where(:reference_id => @systems).select("distinct name")
  end

  def update_multiple_parameters
    if params[:name].empty?
      notice _("No parameters were allocated to the selected systems, can't mass assign.")
      redirect_to systems_path and return
    end

    @skipped_parameters = {}
    counter = 0
    @systems.each do |system|
      skipped = []
      params[:name].each do |name, value|
        next if value.empty?
        if (system_param = system.system_parameters.find_by_name(name))
          counter += 1 if system_param.update_attribute(:value, value)
        else
          skipped << name
        end
        @skipped_parameters[system.name] = skipped unless skipped.empty?
      end
    end
    if @skipped_parameters.empty?
      notice _('Updated all systems!')
      redirect_to(systems_path) and return
    else
      notice _("%s Parameters updated, see below for more information") % (counter)
    end
  end

  def select_multiple_system_group
  end

  def update_multiple_system_group
    # simple validations
    unless (id=params["system_group"]["id"])
      error _('No system group selected!')
      redirect_to(select_multiple_system_group_systems_path) and return
    end
    hg = SystemGroup.find(id) rescue nil
    #update the systems
    @systems.each do |system|
      system.system_group=hg
      system.save(:validate => false)
    end

    notice _('Updated systems: changed system group')
    # We prefer to go back as this does not lose the current search
    redirect_back_or_to systems_path
  end

  def select_multiple_environment
  end

  def update_multiple_environment
    # simple validations
    if (params[:environment].nil?) or (id=params["environment"]["id"]).nil?
      error _('No environment selected!')
      redirect_to(select_multiple_environment_systems_path) and return
    end

    ev = Environment.find(id) rescue nil

    #update the systems
    @systems.each do |system|
      system.environment = (id == 'inherit' && system.system_group.present? ) ? system.system_group.environment : ev
      system.save(:validate => false)
    end

    notice _('Updated systems: changed environment')
    redirect_back_or_to systems_path
  end

  def multiple_destroy
  end

  def multiple_build
  end

  def submit_multiple_build
    @systems.delete_if do |system|
      forward_url_options(system)
      system.setBuild
    end

    missed_systems = @systems.map(&:name).join('<br/>')
    if @systems.empty?
      notice _("The selected systems will execute a build operation on next reboot")
    else
      error _("The following systems failed the build operation: %s") % (missed_systems)
    end
    redirect_to(systems_path)
  end

  def submit_multiple_destroy
    # keep all the ones that were not deleted for notification.
    @systems.delete_if {|system| system.destroy}

    missed_systems = @systems.map(&:name).join('<br/>')
    if @systems.empty?
      notice _("Destroyed selected systems")
    else
      error _("The following systems were not deleted: %s") % (missed_systems)
    end
    redirect_to(systems_path)
  end

  def multiple_disable
  end

  def submit_multiple_disable
    toggle_systemmode false
  end

  def multiple_enable
  end

  def submit_multiple_enable
    toggle_systemmode
  end

  def multiple_puppetrun
    deny_access unless Setting[:puppetrun]
  end

  def update_multiple_puppetrun
    return deny_access unless Setting[:puppetrun]
    if @systems.map(&:puppetrun!).uniq == [true]
      notice _("Successfully executed, check reports and/or log files for more details")
    else
      error _("Some or all systems execution failed, Please check log files for more information")
    end
    redirect_back_or_to systems_path
  end

  def errors
    merge_search_filter("last_report > \"#{Setting[:puppet_interval] + 5} minutes ago\" and (status.failed > 0 or status.failed_restarts > 0)")
    index _("Systems with errors")
  end

  def active
    merge_search_filter("last_report > \"#{Setting[:puppet_interval] + 5} minutes ago\" and (status.applied > 0 or status.restarted > 0)")
    index _("Active Systems")
  end

  def pending
    merge_search_filter("last_report > \"#{Setting[:puppet_interval] + 5} minutes ago\" and (status.pending > 0)")
    index _("Pending Systems")
  end

  def out_of_sync
    merge_search_filter("last_report < \"#{Setting[:puppet_interval] + 5} minutes ago\" and status.enabled = true")
    index _("Systems which didn't run puppet in the last %s") % (view_context.time_ago_in_words((Setting[:puppet_interval]+5).minutes.ago))
  end

  def disabled
    merge_search_filter("status.enabled = false")
    index _("Systems with notifications disabled")
  end

  def process_system_group
    @system_group = SystemGroup.find(params[:system][:system_group_id]) if params[:system][:system_group_id].to_i > 0
    return head(:not_found) unless @system_group

    @architecture    = @system_group.architecture
    @operatingsystem = @system_group.operatingsystem
    @environment     = @system_group.environment
    @domain          = @system_group.domain
    @subnet          = @system_group.subnet

    @system = if params[:system][:id]
      system = System::Base.find(params[:system][:id])
      system = system.becomes System::Managed
      system.attributes = params[:system]
      system
    else
      System.new(params[:system])
    end
    @system.set_system_group_defaults
    render :partial => "form"

  end

  def process_taxonomy
    return head(:not_found) unless @location || @organization
    @system = System.new(params[:system])
    # revert compute resource to "Bare Metal" (nil) if selected
    # compute resource is not included taxonomy
    Taxonomy.as_taxonomy @organization , @location do
      # if compute_resource_id is not in our scope, reset it to nil.
      @system.compute_resource_id = nil unless ComputeResource.exists?(@system.compute_resource_id)
    end
    render :partial => 'form'
  end


  def template_used
    kinds = params[:provisioning] == 'image' ? [TemplateKind.find_by_name('finish')] : TemplateKind.all
    templates = kinds.map do |kind|
      ConfigTemplate.find_template({:kind => kind.name, :operatingsystem_id => params[:operatingsystem_id],
                                   :system_group_id => params[:system_group_id], :environment_id => params[:environment_id]})
    end.compact
    return not_found if templates.empty?
    render :partial => "provisioning", :locals => {:templates => templates}
  end

  private

  def refresh_system
    @system = System::Base.find_by_id(params['system_id'])
    if @system
      unless @system.kind_of?(System::Managed)
        @system      = @system.becomes(System::Managed)
        @system.type = "System::Managed"
      end
      @system.attributes = params['system']
    else
      @system ||= System::Managed.new(params['system'])
    end
    return @system
  end

  def set_system_type
    return unless params[:system] and params[:system][:type]
    type = params[:system].delete(:type) #important, otherwise mass assignment will save the type.
    if type.constantize.new.kind_of?(System::Base)
      @system      = @system.becomes(type.constantize)
      @system.type = type
    else
      error _("invalid type: %s requested") % (type)
      render :unprocessable_entity
    end
  rescue => e
    error _("Something went wrong while changing system type - %s") % (e)
  end

  def taxonomy_scope
    if params[:system]
      @organization = Organization.find_by_id(params[:system][:organization_id])
      @location = Location.find_by_id(params[:system][:location_id])
    end

    if @system
      @organization ||= @system.organization
      @location     ||= @system.location
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
      @system = System::Base.my_systems.find_by_id id.to_i
    else
      @system = System::Base.my_systems.find_by_name id.downcase
      @system ||= System::Base.my_systems.find_by_mac params[:system][:mac] if params[:system] && params[:system][:mac]
    end

    not_found and return false unless @system
  end

  def load_vars_for_ajax
    return unless @system

    taxonomy_scope
    @environment     = @system.environment
    @architecture    = @system.architecture
    @domain          = @system.domain
    @operatingsystem = @system.operatingsystem
    @medium          = @system.medium
    if @system.compute_resource_id && params[:system] && params[:system][:compute_attributes]
      @system.compute_attributes = params[:system][:compute_attributes]
    end
  end

  def find_multiple
  # Lets search by name or id and make sure one of them exists first
    if params[:system_names].present? or params[:system_ids].present?
      @systems = System::Base.where("id IN (?) or name IN (?)", params[:system_ids], params[:system_names] )
      if @systems.empty?
        error _('No systems were found with that id or name')
        redirect_to(systems_path) and return false
      end
    else
      error _('No systems selected')
      redirect_to(systems_path) and return false
    end

    rescue => e
      error _("Something went wrong while selecting systems - %s") % (e)
      redirect_to systems_path
  end

  def toggle_systemmode mode=true
    # keep all the ones that were not disabled for notification.
    @systems.delete_if { |system| system.update_attribute(:enabled, mode) }
    action = mode ? "enabled" : "disabled"

    missed_systems       = @systems.map(&:name).join('<br/>')
    if @systems.empty?
      notice _("%s selected systems") % (action.capitalize)
    else
      error _("The following systems were not %{action}: %{missed_systems}") % { :action => action, :missed_systems => missed_systems }
    end
    redirect_to(systems_path)
  end

  # this is required for template generation (such as pxelinux) which is not done via a web request
  def forward_url_options(system = @system)
    system.url_options = url_options if @system.respond_to?(:url_options)
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
    @system.overwrite = "true" if @system.errors.any? and @system.errors.are_all_conflicts?
  end

end
