require 'foreman/controller/host_details'

class HostsController < ApplicationController
  include Foreman::Controller::HostDetails
  include Foreman::Controller::AutoCompleteSearch

  # actions which don't require authentication and are always treated as the admin user
  ANONYMOUS_ACTIONS=[ :externalNodes, :lookup ]
  SEARCHABLE_ACTIONS= %w[index active errors out_of_sync pending disabled ]
  AJAX_REQUESTS=%w{compute_resource_selected hostgroup_or_environment_selected}
  skip_before_filter :require_login, :only => ANONYMOUS_ACTIONS
  skip_before_filter :require_ssl, :only => ANONYMOUS_ACTIONS
  skip_before_filter :authorize, :only => ANONYMOUS_ACTIONS
  skip_before_filter :session_expiry, :update_activity_time, :only => ANONYMOUS_ACTIONS
  before_filter :set_admin_user, :only => ANONYMOUS_ACTIONS

  before_filter :ajax_request, :only => AJAX_REQUESTS
  before_filter :find_multiple, :only => [:update_multiple_parameters, :multiple_build,
    :select_multiple_hostgroup, :select_multiple_environment, :multiple_parameters, :multiple_destroy,
    :multiple_enable, :multiple_disable, :submit_multiple_disable, :submit_multiple_enable, :update_multiple_hostgroup,
    :update_multiple_environment, :submit_multiple_build, :submit_multiple_destroy, :update_multiple_puppetrun, :multiple_puppetrun]
  before_filter :find_by_name, :only => %w[show edit update destroy puppetrun setBuild cancelBuild
    storeconfig_klasses clone pxe_config toggle_manage power console]

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
        @hosts = search.paginate :page => params[:page], :include => included_associations
        # SQL optimizations queries
        @last_reports = Report.maximum(:id, :group => :host_id, :conditions => {:host_id => @hosts})
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
      format.json { render :json => @host }
    end
  end

  def new
    @host = Host.new :managed => true
    @host.host_parameters.build
  end

  # Clone the host
  def clone
    new = @host.clone
    load_vars_for_ajax
    new.puppetclasses = @host.puppetclasses
    # Clone any parameters as well
    @host.host_parameters.each{|param| new.host_parameters << param.clone}
    flash[:warning] = "The following fields will need reviewing"
    new.valid?
    @host = new
    render :action => :new
  end

  def create
    @host = Host.new(params[:host])
    @host.managed = true
    forward_request_url
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
    forward_request_url
    if @host.update_attributes(params[:host])
      process_success :success_redirect => host_path(@host), :redirect_xhr => request.xhr?
    else
      load_vars_for_ajax
      offer_to_overwrite_conflicts
      process_error
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
    return head(:method_not_allowed) unless request.xhr?

    @environment = Environment.find(params[:environment_id]) unless params[:environment_id].empty?
    @hostgroup   = Hostgroup.find(params[:hostgroup_id])     unless params[:hostgroup_id].empty?
    @host        = Host.find(params[:host_id])               if params[:host_id].to_i > 0
    if @environment or @hostgroup
      @host ||= Host.new
      @host.hostgroup   = @hostgroup if @hostgroup
      @host.environment = @environment if @environment
      render :partial => 'puppetclasses/class_selection', :locals => {:obj => (@host)}
    else
      head(:not_found)
    end
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
        format.html { render :text => @host.info.to_yaml.gsub("\n","<br/>") }
        format.yml { render :text => @host.info.to_yaml }
      end
    rescue
      # failed
      logger.warn "Failed to generate external nodes for #{@host} with #{$!}"
      render :text => 'Unable to generate output, Check log files\n', :status => 412 and return
    end
  end

  def puppetrun
    return deny_access unless Setting[:puppetrun]
    if @host.puppetrun!
      notice "Successfully executed, check log files for more details"
    else
      error @host.errors[:base]
    end
    redirect_to host_path(@host)
  end

  def setBuild
    forward_request_url
    if @host.setBuild
      process_success :success_msg => "Enabled #{@host} for rebuild on next boot", :success_redirect => :back
    else
      process_error :redirect => :back, :error_msg => "Failed to enable #{@host} for installation: #{@host.errors.full_messages}"
    end
  end

  def cancelBuild
    if @host.built(false)
      process_success :success_msg =>  "Canceled pending build for #{@host.name}", :success_redirect => :back
    else
      process_error :redirect => :back, :error_msg => "Failed to cancel pending build for #{@host.name}"
    end
  end

  def power
    return unless @host.compute_resource && params[:power_action]
    action = params[:power_action]
    vm = @host.compute_resource.find_vm_by_uuid(@host.uuid)
    begin
      vm.send(action)
      process_success :success_redirect => :back, :success_msg =>  "#{vm} is now #{vm.ready? ? "running" : "stopped"}"
    rescue => e
      process_error :redirect => :back, :error_msg => "Failed to #{action} #{vm}: #{e}"
    end
  end

  def console
    return unless @host.compute_resource
    @console = @host.compute_resource.console @host.uuid
  rescue => e
    process_error :redirect => :back, :error_msg => "Failed to set console: #{e}"
  end

  def toggle_manage
    if @host.toggle! :managed
      toggle_text = @host.managed ? "" : " no longer"
      process_success :success_msg => "Foreman now#{toggle_text} manages the build cycle for #{@host.name}", :success_redirect => :back
    else
      process_error   :error_msg   => "Failed to modify the build cycle for #{@host}", :redirect => :back
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
      notice "No parameters were allocated to the selected hosts, can't mass assign."
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
      notice 'Updated all hosts!'
      redirect_to(hosts_path) and return
    else
      notice "#{counter} Parameters updated, see below for more information"
    end
  end

  def select_multiple_hostgroup
  end

  def update_multiple_hostgroup
    # simple validations
    unless (id=params["hostgroup"]["id"])
      error 'No Hostgroup selected!'
      redirect_to(select_multiple_hostgroup_hosts_path) and return
    end
    hg = Hostgroup.find(id) rescue nil
    #update the hosts
    @hosts.each do |host|
      host.hostgroup=hg
      host.save(:validate => false)
    end

    notice 'Updated hosts: Changed Hostgroup'
    # We prefer to go back as this does not lose the current search
    redirect_back_or_to hosts_path
  end

  def select_multiple_environment
  end

  def update_multiple_environment
    # simple validations
    if (params[:environment].nil?) or (id=params["environment"]["id"]).nil?
      error 'No Environment selected!'
      redirect_to(select_multiple_environment_hosts_path) and return
    end
    ev = Environment.find(id) rescue nil

    #update the hosts
    @hosts.each do |host|
      host.environment=ev
      host.save(:validate => false)
    end

    notice 'Updated hosts: Changed Environment'
    redirect_back_or_to hosts_path
  end

  def multiple_destroy
  end

  def multiple_build
  end

  def submit_multiple_build
    @hosts.delete_if do |host|
      host.request_url = request.host_with_port if host.respond_to?(:request_url)
      host.setBuild
    end

    missed_hosts = @hosts.map(&:name).join('<br/>')
    if @hosts.empty?
      notice "The selected hosts will execute a build operation on next reboot"
    else
      error "The following hosts failed the build operation: #{missed_hosts}"
    end
    redirect_to(hosts_path)
  end

  def submit_multiple_destroy
    # keep all the ones that were not deleted for notification.
    @hosts.delete_if {|host| host.destroy}

    missed_hosts = @hosts.map(&:name).join('<br/>')
    if @hosts.empty?
      notice "Destroyed selected hosts"
    else
      error "The following hosts were not deleted: #{missed_hosts}"
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
      notice "Successfully executed, check reports and/or log files for more details"
    else
      error "Some or all hosts execution failed, Please check log files for more information"
    end
    redirect_back_or_to hosts_path
  end

  def errors
    merge_search_filter("last_report > \"#{Setting[:puppet_interval] + 5} minutes ago\" and (status.failed > 0 or status.failed_restarts > 0)")
    index "Hosts with errors"
  end

  def active
    merge_search_filter("last_report > \"#{Setting[:puppet_interval] + 5} minutes ago\" and (status.applied > 0 or status.restarted > 0)")
    index "Active Hosts"
  end

  def pending
    merge_search_filter("last_report > \"#{Setting[:puppet_interval] + 5} minutes ago\" and (status.pending > 0)")
    index "Pending Hosts"
  end

  def out_of_sync
    merge_search_filter("last_report < \"#{Setting[:puppet_interval] + 5} minutes ago\" and status.enabled = true")
    index "Hosts which didn't run puppet in the last #{Setting[:puppet_interval] + 5} minutes"
  end

  def disabled
    merge_search_filter("status.enabled = false")
    index "Hosts with notifications disabled"
  end

  def process_hostgroup
    @hostgroup = Hostgroup.find(params[:hostgroup_id]) if params[:hostgroup_id].to_i > 0
    return head(:not_found) unless @hostgroup

    @architecture    = @hostgroup.architecture
    @operatingsystem = @hostgroup.operatingsystem
    @environment     = @hostgroup.environment
    @domain          = @hostgroup.domain
    @subnet          = @hostgroup.subnet

    @host = Host.new
    @host.hostgroup = @hostgroup
    @host.compute_resource_id = params[:compute_resource_id] if params[:compute_resource_id].present?
    @host.set_hostgroup_defaults


    render :update do |page|
      [:environment_id, :puppet_ca_proxy_id, :puppet_proxy_id].each do |field|
        page["*[id*=#{field}]"].val(@hostgroup.send(field)) if @hostgroup.send(field).present?
      end
      page['#puppet_klasses'].html(render(:partial => 'puppetclasses/class_selection', :locals => {:obj => @host})) if @environment

      if SETTINGS[:unattended]
        page['*[id*=root_pass]'].val(@hostgroup.root_pass)
        if !@host.compute_resource_id and (@hypervisor = @hostgroup.hypervisor)
          @hypervisor.connect
          # we are in a view context
          controller.send(:update_hypervisor_details, @host, page)
          @hypervisor.disconnect
        end

        if @architecture
          page['#os_select'].html(render(:partial => 'common/os_selection/architecture', :locals => {:item => @host}))
          page['#*[id*=architecture_id]'].val(@architecture.id)
        end

        page['#media_select'].html(render(:partial => 'common/os_selection/operatingsystem', :locals => {:item => @host})) if @operatingsystem

        if @domain
          page['*[id*=domain_id]'].val(@domain.id)
          if @subnet
            page['#subnet_select'].html(render(:partial => 'common/domain', :locals => {:item => @host}))
            page['#host_subnet_id'].val(@subnet.id).change
            page['#sp_subnet'].html(render(:partial => 'hosts/sp_subnet', :locals => {:item => @host}))
          end
        end
      end
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
    @hypervisor      = @host.hypervisor if @host.respond_to?(:hypervisor)
    if @host.compute_resource_id && params[:host] && params[:host][:compute_attributes]
      @host.compute_attributes = params[:host][:compute_attributes]
    end

  end

  def find_multiple
  # Lets search by name or id and make sure one of them exists first
    if params[:host_names].present? or params[:host_ids].present?
      @hosts = Host.all(:conditions => ["id IN (?) or name IN (?)", params[:host_ids], params[:host_names] ])
      if @hosts.empty?
        error 'No hosts were found with that id or name'
        redirect_to(hosts_path) and return false
      end
    else
      error 'No Hosts selected'
      redirect_to(hosts_path) and return false
    end

    rescue => e
      error "Something went wrong while selecting hosts - #{e}"
      redirect_to hosts_path
  end

  def toggle_hostmode mode=true
    # keep all the ones that were not disabled for notification.
    @hosts.delete_if { |host| host.update_attribute(:enabled, mode) }
    action = mode ? "enabled" : "disabled"

    missed_hosts       = @hosts.map(&:name).join('<br/>')
    if @hosts.empty?
      notice "#{action.capitalize} selected hosts"
    else
      error "The following hosts were not #{action}: #{missed_hosts}"
    end
    redirect_to(hosts_path)
  end

  # Returns the associations to include when doing a search.
  # If the user has a fact_filter then we need to include :fact_values
  # We do not include most associations unless we are processing a html page
  def included_associations(include = [])
    include += [:hostgroup, :domain, :operatingsystem, :environment, :model, :host_parameters]
    include += [:fact_values] if User.current.user_facts.any?
    include
  end

  # this is required for template generation (such as pxelinux) which is not done via a web request
  def forward_request_url
    @host.request_url = request.host_with_port if @host.respond_to?(:request_url)
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
