class HostsController < ApplicationController
  include Facts
  # actions which don't require authentication and are always treathed as the admin user
  ANONYMOUS_ACTIONS=[ :query, :externalNodes, :lookup ]
  skip_before_filter :require_login, :only => ANONYMOUS_ACTIONS
  skip_before_filter :require_ssl, :only => ANONYMOUS_ACTIONS
  skip_before_filter :authorize, :only => ANONYMOUS_ACTIONS
  before_filter :set_admin_user, :only => ANONYMOUS_ACTIONS

  before_filter :find_hosts, :only => :query
  before_filter :ajax_methods, :only => [:environment_selected, :architecture_selected, :os_selected]
  before_filter :find_multiple, :only => [:multiple_actions, :update_multiple_parameters,
    :select_multiple_hostgroup, :select_multiple_environment, :multiple_parameters, :multiple_destroy,
    :multiple_enable, :multiple_disable, :submit_multiple_disable, :submit_multiple_enable]
  before_filter :find_by_name, :only => %w[show edit update destroy puppetrun setBuild cancelBuild report
    reports facts storeconfig_klasses clone externalNodes pxe_config]

  filter_parameter_logging :root_pass
  helper :hosts, :reports

  def index

    # restrict allowed hosts list based on the user permissions
    @search  = User.current.admin? ? Host.search(params[:search]) : Host.my_hosts.search(params[:search])

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
    respond_to do |format|
      if @host.save
        format.html do
          notice "Successfully created host."
          redirect_to @host
        end
        format.json { render :json => @host, :status => :created, :location => @host }
      else
        format.html do
          load_vars_for_ajax
          render :action => 'new'
        end
        format.json { render :json => @host.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @host.managed = (@host.operatingsystem_id and @host.architecture_id and (@host.ptable_id or not @host.disk.empty?)) ? true : false
    load_vars_for_ajax
  end

  def update
    @host.managed = (@host.operatingsystem_id and @host.architecture_id and (@host.ptable_id or not @host.disk.empty?)) ? true : false
    if @host.update_attributes(params[:host])
      notice "Successfully updated host."
      redirect_to @host
    else
      load_vars_for_ajax
      render :action => 'edit'
    end
  end

  def destroy
    if @host.destroy
      respond_to do |format|
        format.html { notice "Successfully destroyed host." }
        format.json { render :json => @host, :status => :ok and return }
      end
    else
      respond_to do |format|
        format.html { error @host.errors.full_messages.join("<br/>") }
        format.json { render :json => @host.errors, :status => :unprocessable_entity and return }
      end
    end
    redirect_to hosts_url
  end

  # form AJAX methods

  def environment_selected
    if params[:environment_id].to_i > 0 and @environment = Environment.find(params[:environment_id])
      render :partial => 'puppetclasses/class_selection', :locals => {:obj => (@host ||= Host.new)}
    else
      return head(:not_found)
    end
  end

  def architecture_selected
    assign_parameter "architecture"
  end

  def os_selected
    assign_parameter "operatingsystem"
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
    redirect_to :back
  end

  def setBuild
    if @host.setBuild != false
      respond_to  do |format|
        format.html { notice "Enabled #{@host.name} for rebuild on next boot" }
        format.json { render :json => @host, :status => :ok and return }
      end
    else
      respond_to do |format|
        format.html { error "Failed to enable #{@host.name} for installation" }
        format.json { render :json => @host.errors, :status => :unprocessable_entity and return }
      end
    end
    redirect_to :back
  end

  def cancelBuild
    if @host.built(false)
      notice "Canceled pending build for #{@host.name}"
    else
      error "Failed to cancel pending build for #{@host.name}"
    end
    redirect_to :back
  end

  # shows the last report for a host
  def report
    # is it safe to assume that the biggest ID is the last report?
    redirect_to :controller => "reports", :action => "show", :id => Report.maximum('id', :conditions => {:host_id => @host})
  end

  # shows reports for a certain host
  def reports
    # set defaults search order - cant use default scope due to bug in AR
    # http://github.com/binarylogic/searchlogic/issues#issue/17
    params[:search] ||= {}
    params[:search][:order] ||=  "ascend_by_reported_at"
    @search  = Report.search(params[:search])
    @reports = @search.paginate(:page => params[:page], :conditions => {:host_id => @host}, :include => :host)
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

  def facts
    respond_to do |format|
      format.html { redirect_to fact_values_path(:search => {:host_name_eq => @host})}
      format.json { render :json => @host.facts_hash }
    end
  end

  def pxe_config
    redirect_to(:controller => "unattended", :action => "pxe_#{@host.operatingsystem.pxe_type}_config", :host_id => @host) if @host
  end

  def storeconfig_klasses
  end

  # multiple host selection methods

  # present the available actions to the user
  def multiple_actions
  end

  def multiple_parameters
    @parameters = HostParameter.reference_id_is(@hosts).all(:select => "distinct name")
  end

  def reset_multiple
    session[:selected] = []
    flash.keep
    notice 'Selection cleared.'
    redirect_to hosts_path and return
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
    session[:selected] = []
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
    if (id=params["hostgroup"]["id"]).empty?
      error 'No Hostgroup selected!'
      redirect_to(select_multiple_hostgroup_hosts) and return
    end
    if (hg = Hostgroup.find id).nil?
      error 'Empty Hostgroup selected!'
      redirect_to(select_multiple_hostgroup_hosts) and return
    end

    #update the hosts
    Host.find(session[:selected]).each do |host|
      host.hostgroup=hg
      host.save(perform_validation = false)
    end

    session[:selected] = []
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
    Host.find(session[:selected]).each do |host|
      host.environment=ev
      host.save(perform_validation = false)
    end

    session[:selected] = []
    notice 'Updated hosts: Changed Environment'
    redirect_to(hosts_path)
  end

  def multiple_destroy
  end

  def submit_multiple_destroy
    # destroy the hosts
    hosts = Host.find(session[:selected])
    # keep all the ones that were not deleted for notification.
    hosts.delete_if {|host| host.destroy}

    session[:selected] = []
    missed_hosts       = hosts.map(&:name).join('<br/>')
    notice hosts.empty? ? "Destroyed selected hosts" : "The following hosts were not deleted: #{missed_hosts}"
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

  # AJAX method to update our session each time a host has been selected
  # we are using AJAX and JS as the user might select multiple hosts across different pages (or requests).
  def save_checkbox
    return unless request.xhr?
    session[:selected] ||= []
    case params[:is_checked]
    when "true"
      session[:selected] << params[:box]
    when "false"
      session[:selected].delete params[:box]
    end
    render :nothing => true
  end

  def errors
    show_hosts Host.recent.with_error, "Hosts with errors"
  end

  def active
    show_hosts Host.recent.with_changes, "Active Hosts"
  end

  def out_of_sync
    show_hosts Host.out_of_sync, "Hosts which didn't run puppet in the last #{SETTINGS[:puppet_interval]} minutes"
  end

  def disabled
    show_hosts Host.alerts_disabled, "Hosts with notifications disabled"
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

  def assign_parameter name
    if params["#{name}_id"].to_i > 0 and eval("@#{name} = #{name.capitalize}.find(params['#{name}_id'])")
      render :partial => name, :locals => {:host => (@host ||= Host.new)}
    else
      return head(:not_found)
    end
  end

  def load_vars_for_ajax
    return unless @host
    @environment = @host.environment
    @architecture = @host.architecture
    @operatingsystem = @host.operatingsystem
  end

  def find_multiple
    if session[:selected].empty?
      error 'No Hosts selected'
      redirect_to(hosts_path)
    else
      begin
        @hosts = Host.find(session[:selected], :order => "hostgroup_id ASC")
      rescue
        error "Something went wrong while selecting hosts - resetting ..."
        flash.keep(:foreman_error)
        redirect_to reset_multiple_hosts_path
      end
    end
  end

  def toggle_hostmode mode=true
    # keep all the ones that were not disabled for notification.
    @hosts.delete_if { |host| host.update_attribute(:enabled, mode) }
    action = mode ? "enabled" : "disabled"

    session[:selected] = []
    missed_hosts       = hosts.map(&:name).join('<br/>')
    notice @hosts.empty? ? "#{action.capitalize} selected hosts" : "The following hosts were not #{action}: #{missed_hosts}"
    redirect_to(hosts_path) and return
  end

  # Returns the associationes to include when doing a search.
  # If the user has a fact_filter then we need to include :fact_values
  # We do not include most associations unless we are processing a html page
  def included_associations(include = [])
    include += [:hostgroup, :domain, :operatingsystem, :environment, :model] unless request_json?
    include += [:fact_values] if User.current.user_facts.any?
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
      format.json { render :json => @search.all(:select => "name", :include => included_associations).map(&:name) }
      format.yaml { render :text => @search.all(:select => "name", :include => included_associations).map(&:name).to_yaml }
    end

  end

  def show_hosts list, title
    @search = User.current.admin? ? list.search(params[:search]) : list.my_hosts.search(params[:search])
    render_hosts title
  end

end
