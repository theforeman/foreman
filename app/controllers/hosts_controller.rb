class HostsController < ApplicationController
  include Facts
  include Foreman::Controller::HostDetails
  include Foreman::Controller::AutoCompleteSearch

  # actions which don't require authentication and are always treathed as the admin user
  ANONYMOUS_ACTIONS=[ :query, :externalNodes, :lookup ]
  skip_before_filter :require_login, :only => ANONYMOUS_ACTIONS
  skip_before_filter :require_ssl, :only => ANONYMOUS_ACTIONS
  skip_before_filter :authorize, :only => ANONYMOUS_ACTIONS
  before_filter :set_admin_user, :only => ANONYMOUS_ACTIONS

  before_filter :find_hosts, :only => :query
  before_filter :ajax_methods, :only => [:hostgroup_or_environment_selected]
  before_filter :find_multiple, :only => [:update_multiple_parameters, :multiple_build,
    :select_multiple_hostgroup, :select_multiple_environment, :multiple_parameters, :multiple_destroy,
    :multiple_enable, :multiple_disable, :submit_multiple_disable, :submit_multiple_enable, :update_multiple_hostgroup,
    :update_multiple_environment, :submit_multiple_build, :submit_multiple_destroy]
  before_filter :find_by_name, :only => %w[show edit update destroy puppetrun setBuild cancelBuild report
    reports facts storeconfig_klasses clone externalNodes pxe_config toggle_manage]
  after_filter :disconnect_from_hypervisor, :only => :hypervisor_selected

  filter_parameter_logging :root_pass
  helper :hosts, :reports

  def index
    begin
      # restrict allowed hosts list based on the user permissions
      my_hosts  = User.current.admin? ? Host : Host.my_hosts
      @search = my_hosts.search_for(params[:search],:order => params[:order], :group => 'hosts.id')
    rescue => e
      error e.to_s
      @search = my_hosts.search_for ''
    end
    render_hosts
  end

  def show
    respond_to do |format|
      format.html {
        # filter graph time range
        @range = (params["range"].empty? ? 7 : params["range"].to_i)
        range = @range.days.ago
        graphs = @host.graph(range)

        # runtime graph
        data = { :labels => graphs[:runtime_labels], :values => graphs[:runtime] }
        options = { :title => "Runtime"}
        @runtime_graph = setgraph(GoogleVisualr::AnnotatedTimeLine.new, data, options)

        # resource graph
        data = { :labels => graphs[:resources_labels], :values => graphs[:resources] }
        options = { :title => "Resource", :width => 800, :height => 300, :legend => 'bottom'}
        @resource_graph = setgraph(GoogleVisualr::LineChart.new, data, options)

        # summary report text
        @report_summary = Report.summarise(range, @host)
      }
      format.yaml { render :text => @host.info.to_yaml }
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
    flash[:error_customisation] = {:header_message => nil, :class => "flash notice", :id => nil,
      :message => "The following fields will need reviewing:" }
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

  def domain_selected
    assign_parameter "domain"
  end

  def hostgroup_or_environment_selected
     @environment = Environment.find(params[:environment_id]) if params[:environment_id].to_i > 0
     @hostgroup   = Hostgroup.find(params[:hostgroup_id])     if params[:hostgroup_id].to_i   > 0
     if @environment or @hostgroup
      @host ||= Host.new
      @host.hostgroup   = @hostgroup if @hostgroup
      @host.environment = @environment if @environment
      render :partial => 'puppetclasses/class_selection', :locals => {:obj => (@host)}
    else
      return head(:not_found)
    end
  end

  def hypervisor_selected
    hypervisor_id = params[:host_hypervisor_id].to_i

    # bare metal selected
    hypervisor_defaults and return if hypervisor_id == 0

    @host ||= Host.new
    if ((@host.hypervisor_id = hypervisor_id) > 0) and (@hypervisor = Hypervisor.find(@host.hypervisor_id))
      begin
        @hypervisor.connect
      rescue => e
        # we reset to default
        @host.hypervisor_id = nil
        logger.warn e.to_s
        hypervisor_defaults(e.to_s) and return
      end

      @guest = Virt::Guest.new({:name => (@host.try(:name) || "new-#{Time.now}.to_i")})

      render :update do |page|
        page.replace_html :virtual_machine, :partial => "hypervisor"
        page << "if ($('host_mac')) {"
        page.remove :host_mac_label
        page.remove :host_mac
        page << " }"
      end
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
    if GW::Puppet.run @host.name
      notice "Successfully executed, check log files for more details"
    else
      error "Failed, check log files"
    end
    redirect_to host_path(@host)
  end

  def setBuild
    forward_request_url
    if @host.setBuild != false
      process_success :success_msg => "Enabled #{@host.name} for rebuild on next boot", :success_redirect => :back
    else
      process_error :redirect => :back, :error_msg => "Failed to enable #{@host.name} for installation: #{@host.errors.full_messages.join("br")}"
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
    @parameters = HostParameter.reference_id_is(@hosts).all(:select => "distinct name")
  end

  def update_multiple_parameters
    if params[:name].empty?
      notice "No parameters were allocted to the selected hosts, can't mass assign."
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
    unless (hg = Hostgroup.find id)
      error 'Empty Hostgroup selected!'
      redirect_to(select_multiple_hostgroup_hosts_path) and return
    end

    #update the hosts
    @hosts.each.each do |host|
      host.hostgroup=hg
      host.save(perform_validation = false)
    end

    notice 'Updated hosts: Changed Hostgroup'
    redirect_to(hosts_path)
  end

  def select_multiple_environment
  end

  def update_multiple_environment
    # simple validations
    if (params[:environment].nil?) or (id=params["environment"]["id"]).nil?
      error 'No Environment selected!'
      redirect_to(select_multiple_environment_hosts_path) and return
    end
    if (ev = Environment.find id).nil?
      error 'Empty Environment selected!'
      redirect_to(select_multiple_environment_hosts_path) and return
    end

    #update the hosts
    @hosts.each do |host|
      host.environment=ev
      host.save(perform_validation = false)
    end

    notice 'Updated hosts: Changed Environment'
    redirect_to(hosts_path)
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

  def errors
    params[:search]="last_report > \"#{SETTINGS[:puppet_interval] + 5} minutes ago\" and (status.failed > 0 or status.failed_restarts > 0 or status.skipped > 0)"
    show_hosts Host.recent.with_error, "Hosts with errors"
  end

  def active
    params[:search]="last_report > \"#{SETTINGS[:puppet_interval] + 5} minutes ago\" and (status.applied > 0 or status.restarted > 0)"
    show_hosts Host.recent.with_changes, "Active Hosts"
  end

  def out_of_sync
    params[:search]="last_report > \"#{SETTINGS[:puppet_interval]} minutes ago\" and status.enabled = true"
    show_hosts Host.out_of_sync, "Hosts which didn't run puppet in the last #{SETTINGS[:puppet_interval]} minutes"
  end

  def disabled
    params[:search]="status.enabled = false"
    show_hosts Host.alerts_disabled, "Hosts with notifications disabled"
  end

  def process_hostgroup
    @hostgroup = Hostgroup.find(params[:hostgroup_id]) if params[:hostgroup_id].to_i > 0
    return head(:not_found) unless @hostgroup

    @architecture    = @hostgroup.architecture
    @operatingsystem = @hostgroup.operatingsystem
    @environment     = @hostgroup.environment

    render :update do |page|
      page['host_environment_id'].value = @hostgroup.environment_id if @hostgroup.environment_id
      # process_hostgroup is only ever called for new host records therefore the assigned value can never be @hostgroup.puppetmaster_name
      page['host_puppetproxy_id'].value = @hostgroup.puppetmaster.id if @hostgroup.puppetca?
      if @environment
        @host = Host.new
        @host.hostgroup   = @hostgroup
        @host.environment = @environment
        page.replace_html :classlist, :partial => 'puppetclasses/class_selection', :locals => {:obj => (@host)}
      end

      if (SETTINGS[:unattended].nil? or SETTINGS[:unattended])
        page['host_root_pass'].value = @hostgroup.root_pass

        if @architecture
          page.replace_html :architecture_select, :partial => 'common/os_selection/architecture', :locals => {:item => @hostgroup}
          page['host_architecture_id'].value = @architecture.id
        end
        if @operatingsystem
          page['host_operatingsystem_id'].value = @operatingsystem.id
          page.replace_html :operatingsystem_select, :partial => 'common/os_selection/operatingsystem', :locals => {:item => @hostgroup}
        end
      end
    end
  end

  private
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
      raise invalid_request and return
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
      list = Host.hostgroup_name_eq(k).send(state).map(&:name)
      @hosts = counter == 0 ? list : @hosts & list
      counter +=1
    end unless group.nil?

    not_found if @hosts.empty?
  end

  def ajax_methods
    return head(:method_not_allowed) unless request.xhr?
    @host = Host.find(params[:id]) unless params[:id].empty?
  end

  def load_vars_for_ajax
    return unless @host
    @environment     = @host.environment
    @architecture    = @host.architecture
    @domain          = @host.domain
    @operatingsystem = @host.operatingsystem
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
    include += [:hostgroup, :domain, :operatingsystem, :environment, :model] unless request_json?
    include += [:fact_values] if User.current.user_facts.any?
    return include
  end

  def render_hosts title=nil
    respond_to do |format|
      format.html do
        # You can see a host if you can CRUD it
        @hosts = @search.paginate :page => params[:page], :include => included_associations
        @via   = "fact_values_"
        # SQL optimizations queries
        @last_reports = Report.maximum(:id, :group => :host_id, :conditions => {:host_id => @hosts})
        @fact_kernels = FactValue.all(:select => "host_id, fact_values.value", :joins => [:host, :fact_name],
                                     :conditions => {"fact_values.host_id" => @hosts, "fact_names.name" => 'kernel'})
        # rendering index page for  non index page requests (out of sync hosts etc)
        render :index if title and @title = title
      end
      format.json { render :json => @search.all(:select => "hosts.name", :include => included_associations).map(&:name) }
      format.yaml { render :text => @search.all(:select => "hosts.name", :include => included_associations).map(&:name).to_yaml }
    end

  end

  def show_hosts list, title
    @search = User.current.admin? ? list.search(params[:search]) : list.my_hosts.search(params[:search])
    render_hosts title
  end

  # this is required for template generation (such as pxelinux) which is not done via a web request
  def forward_request_url
    @host.request_url = request.host_with_port if @host.respond_to?(:request_url)
  end

  def hypervisor_defaults msg = nil
    @hypervisor = nil
    render :update do |page|
      page.alert(msg) if msg
      page.replace_html :virtual_machine, :partial => "hypervisor"
      # you can only select bare metal after you successfully selected a hypervisor before
      page << "if (!$('host_mac')) {"
      page.insert_html :after, :host_ip, :partial => "mac"
      page[:host_hypervisor_id].value = ""
      page << " }"
    end
  end

  def disconnect_from_hypervisor
    @hypervisor.disconnect if @hypervisor
  end

end
