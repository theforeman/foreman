require 'foreman/controller/host_details'

class HostsController < ApplicationController
  include Foreman::Controller::HostDetails
  include Foreman::Controller::AutoCompleteSearch

  # actions which don't require authentication and are always treated as the admin user
  ANONYMOUS_ACTIONS=[ :query, :externalNodes, :lookup ]
  skip_before_filter :require_login, :only => ANONYMOUS_ACTIONS
  skip_before_filter :require_ssl, :only => ANONYMOUS_ACTIONS
  skip_before_filter :authorize, :only => ANONYMOUS_ACTIONS
  skip_before_filter :session_expiry, :update_activity_time, :only => ANONYMOUS_ACTIONS
  before_filter :set_admin_user, :only => ANONYMOUS_ACTIONS

  before_filter :find_hosts, :only => :query
  before_filter :find_multiple, :only => [:update_multiple_parameters, :multiple_build,
    :select_multiple_hostgroup, :select_multiple_environment, :multiple_parameters, :multiple_destroy,
    :multiple_enable, :multiple_disable, :submit_multiple_disable, :submit_multiple_enable, :update_multiple_hostgroup,
    :update_multiple_environment, :submit_multiple_build, :submit_multiple_destroy, :update_multiple_puppetrun, :multiple_puppetrun]
  before_filter :find_by_name, :only => %w[show edit update destroy puppetrun setBuild cancelBuild
    storeconfig_klasses clone pxe_config toggle_manage]

  helper :hosts, :reports

  def index (title = nil)
    begin
      # restrict allowed hosts list based on the user permissions
      my_hosts = User.current.admin? ? Host : Host.my_hosts
      search   = my_hosts.search_for(params[:search],:order => params[:order])
    rescue => e
      error e.to_s
      search = my_hosts.search_for ''
    end
      respond_to do |format|
      format.html do
        @hosts = search.paginate :page => params[:page], :include => included_associations
        # SQL optimizations queries
        @last_reports = Report.maximum(:id, :group => :host_id, :conditions => {:host_id => @hosts})
        # rendering index page for non index page requests (out of sync hosts etc)
        render :index if title and @title = title
      end
      format.json { render :json => search.all(:select => "hosts.name", :include => included_associations).map(&:name) }
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
      process_success :success_redirect => @host
    else
      load_vars_for_ajax
      process_error
    end
  end

  def edit
    load_vars_for_ajax
  end

  def update
    forward_request_url
    if @host.update_attributes(params[:host])
      process_success :success_redirect => @host
    else
      load_vars_for_ajax
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
      return head(:not_found)
    end
  end

  #returns a yaml file ready to use for puppet external nodes script
  #expected a fqdn parameter to provide hostname to lookup
  #see example script in extras directory
  #will return HTML error codes upon failure

  def externalNodes
    @host ||= Host.find_by_name(params[:name]) if params[:name]
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
    if GW::Puppet.run @host.name
      notice "Successfully executed, check log files for more details"
    else
      error "Failed, Please check log files for more information"
    end
    redirect_to host_path(@host)
  end

  def setBuild
    forward_request_url
    if @host.setBuild != false
      process_success :success_msg => "Enabled #{@host.name} for rebuild on next boot", :success_redirect => :back
    else
      process_error :redirect => :back, :error_msg => ["Failed to enable #{@host.name} for installation", @host.errors.full_messages]
    end
  end

  def cancelBuild
    if @host.built(false)
      process_success :success_msg =>  "Canceled pending build for #{@host.name}", :success_redirect => :back
    else
      process_error :redirect => :back, :error_msg => "Failed to cancel pending build for #{@host.name}"
    end
  end

  def query
    if @verbose
      @hosts.map! do |host|
        hash = {}
        h = Host.find_by_name host
        hash[host] = h.info
        hash[host]["facts"]= h.facts_hash
        hash
      end
    end
    respond_to do |format|
      format.html
      format.yml { render :text => @hosts.to_yaml }
    end
  end

  def toggle_manage
    if @host.toggle! :managed
      toggle_text = @host.managed ? "" : " no longer"
      process_success :success_msg => "Foreman now#{toggle_text} manages the build cycle for #{@host.name}", :success_redirect => :back
    else
      process_error   :error_msg   => "Failed to modify the build cycle for #{@host.name}", :redirect => :back
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
        if host_param = host.host_parameters.find_by_name(name)
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
    return deny_access unless Setting[:puppetrun]
  end

  def update_multiple_puppetrun
    return deny_access unless Setting[:puppetrun]
    if GW::Puppet.run @hosts.map(&:fqdn)
      notice "Successfully executed, check reports and/or log files for more details"
    else
      error "Some or all hosts execution failed, Please check log files for more information"
    end
    redirect_back_or_to hosts_path
  end

  def errors
    params[:search]="last_report > \"#{Setting[:puppet_interval] + 5} minutes ago\" and (status.failed > 0 or status.failed_restarts > 0)"
    index "Hosts with errors"
  end

  def active
    params[:search]="last_report > \"#{Setting[:puppet_interval] + 5} minutes ago\" and (status.applied > 0 or status.restarted > 0)"
    index "Active Hosts"
  end

  def pending
    params[:search]="last_report > \"#{Setting[:puppet_interval] + 5} minutes ago\" and (status.pending > 0)"
    index "Pending Hosts"
  end

  def out_of_sync
    params[:search]="last_report < \"#{Setting[:puppet_interval] + 5} minutes ago\" and status.enabled = true"
    index "Hosts which didn't run puppet in the last #{Setting[:puppet_interval] + 5} minutes"
  end

  def disabled
    params[:search]="status.enabled = false"
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
    @host.set_hostgroup_defaults

    render :update do |page|
      page['*[id*=environment_id]'].val(@hostgroup.environment_id) if @hostgroup.environment_id
      # process_hostgroup is only ever called for new host records therefore the assigned value can never be @hostgroup.puppetmaster_name
      # This means that we should use the puppetproxy display type as new hosts should use this feature
      page['*[id*=puppetproxy_id]'].val(@hostgroup.puppetca? ? @hostgroup.puppetmaster.id : "")

      page['#puppet_klasses'].html(render(:partial => 'puppetclasses/class_selection', :locals => {:obj => @host})) if @environment

      if SETTINGS[:unattended]
        page['*[id*=root_pass]'].val(@hostgroup.root_pass)
        if (@hypervisor = @hostgroup.hypervisor)
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
    templates = TemplateKind.all.map do |kind|
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

  def find_hosts
    fact, klass, group = params[:fact], params[:class], params[:hostgroup]

    @verbose = params[:verbose] == "yes"

    case params[:state]
    when "out_of_sync"
      state = "out_of_sync"
    when "all"
      state = "all"
    when "active", nil
      state = "recent"
    else
      raise invalid_request
    end

    @hosts = Host.send(state).map(&:name) if fact.empty? and klass.empty? and group.empty?
    @hosts ||= []
    counter = 0

    # TODO: rewrite this part, my brain stopped working
    # it should be possible for a one join
    fact.each do |f|
      # split facts based on name => value pairs
      q = f.split("-seperator-")
      invalid_request unless q.size == 2
      list = Host.with_fact(*q).send(state).map(&:name)
      @hosts = counter == 0 ? list : @hosts & list
      counter +=1
    end unless fact.nil?

    klass.each do |k|
      list = Host.with_class(k).send(state).map(&:name)
      @hosts = counter == 0 ? list : @hosts & list
      counter +=1
    end unless klass.nil?

    group.each do |k|
      list = Host.joins(:hostgroup).where("hostgroups.name" => k).send(state).map(&:name)
      @hosts = counter == 0 ? list : @hosts & list
      counter +=1
    end unless group.nil?

    not_found if @hosts.empty?
  end

  def load_vars_for_ajax
    return unless @host
    @environment     = @host.environment
    @architecture    = @host.architecture
    @domain          = @host.domain
    @operatingsystem = @host.operatingsystem
    @medium          = @host.medium
    @hypervisor      = @host.hypervisor if @host.respond_to?(:hypervisor)
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
    redirect_to(hosts_path) and return
  end

  # Returns the associationes to include when doing a search.
  # If the user has a fact_filter then we need to include :fact_values
  # We do not include most associations unless we are processing a html page
  def included_associations(include = [])
    include += [:hostgroup, :domain, :operatingsystem, :environment, :model] unless api_request?
    include += [:fact_values] if User.current.user_facts.any?
    return include
  end

  # this is required for template generation (such as pxelinux) which is not done via a web request
  def forward_request_url
    @host.request_url = request.host_with_port if @host.respond_to?(:request_url)
  end

end
