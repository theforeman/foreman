class HostsController < ApplicationController
  before_filter :require_login, :except => [ :query, :externalNodes, :lookup ]
  before_filter :require_ssl, :except => [ :query, :externalNodes, :lookup ]
  before_filter :find_hosts, :only => :query
  before_filter :ajax_methods, :only => [:environment_selected, :architecture_selected, :os_selected]
  before_filter :find_multiple, :only => [:multiple_actions, :update_multiple_parameters,
    :select_multiple_hostgroup, :select_multiple_environment, :multiple_parameters, :multiple_destroy,
    :multiple_enable, :multiple_disable, :submit_multiple_disable, :submit_multiple_enable]

  helper :hosts, :reports

  def index
    @search = Host.search(params[:search])
    @hosts = @search.paginate :page => params[:page], :include => [:hostgroup, :domain, :operatingsystem, :environment]
    @via    = "fact_values_"
    @last_reports = Report.maximum(:id, :group => :host_id, :conditions => {:host_id => @hosts})
  end

  def show
    # filter graph time range
    @range = (params["range"].empty? ? 7 : params["range"].to_i)
    range = @range.days.ago

    @host = Host.find params[:id]
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
  end

  def new
    @host = Host.new
    @host.host_parameters.build
  end

  # Clone the host
  def clone
    @original = Host.find(params[:id])
    @host = @original.clone
    load_vars_for_ajax
    @host.puppetclasses = @original.puppetclasses
    # Clone any parameters as well
    @original.host_parameters.each{|param| @host.host_parameters << param.clone}
    flash[:error_customisation] = {:header_message => nil, :class => "flash notice", :id => nil,
      :message => "The following fields will need reviewing:" }
    @host.valid?
    render :action => :new
  end

  def create
    @host = Host.new(params[:host])
    if @host.save
      flash[:foreman_notice] = "Successfully created host."
      redirect_to @host
    else
      load_vars_for_ajax
      render :action => 'new'
    end
  end

  def edit
    @host = Host.find(params[:id])
    load_vars_for_ajax
  end

  def update
    @host = Host.find(params[:id])
    if @host.update_attributes(params[:host])
      flash[:foreman_notice] = "Successfully updated host."
      redirect_to @host
    else
      load_vars_for_ajax
      render :action => 'edit'
    end
  end

  def destroy
    @host = Host.find(params[:id])
    if @host.destroy
      flash[:foreman_notice] = "Successfully destroyed host."
    else
      flash[:foreman_error] = @host.errors.full_messages.join("<br>")
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
    # check our parameters and look for a host
    if params[:id] and @host = Host.find(params[:id])
    elsif params["name"] and @host = Host.find(:first,:conditions => ["name = ?",params["name"]])
    else
      render :text => '404 Not Found', :status => 404 and return
    end

    begin
      respond_to do |format|
        format.html { render :text => @host.info.to_yaml.gsub("\n","<br>") }
        format.yml { render :text => @host.info.to_yaml }
      end
    rescue
      # failed
      logger.warn "Failed to generate external nodes for #{@host.name} with #{$!}"
      render :text => 'Unable to generate output, Check log files', :status => 412 and return
    end
  end

  def puppetrun
    host = Host.find params[:id]
    if GW::Puppet.run host.name
      flash[:foreman_notice] = "Successfully executed, check log files for more details"
    else
      flash[:foreman_error] = "Failed, check log files"
    end
    redirect_to :back
  end

  def setBuild
    host = Host.find params[:id]
    if host.setBuild != false
      flash[:foreman_notice] = "Enabled #{host.name} for rebuild on next boot"
    else
      flash[:foreman_error] = "Failed to enable #{host.name} for installation"
    end
    redirect_to :back
  end

  def cancelBuild
    host = Host.find params[:id]
    if host.built(false)
      flash[:foreman_notice] = "Canceled pending build for #{host.name}"
    else
      flash[:foreman_error] = "Failed to cancel pending build for #{host.name}"
    end
    redirect_to :back
  end

  # generates a link to Puppetmaster RD graphs
  def rrdreport
    if SETTINGS[:rrd_report_url].nil? or (host=Host.find(params[:id])).last_report.nil?
      render :text => "Sorry, no graphs for this host"
    else
      render :partial => "rrdreport", :locals => { :host => host}
    end
  end

  # shows the last report for a host
  def report
    # is it safe to assume that the biggest ID is the last report?
    redirect_to :controller => "reports", :action => "show", :id => Report.maximum('id', :conditions => {:host_id => params[:id]})
  end

  # shows all reports for a certain host
  def reports
    @host = Host.find(params[:id])
    # set defaults search order - cant use default scope due to bug in AR
    # http://github.com/binarylogic/searchlogic/issues#issue/17
    params[:search] ||= {}
    params[:search][:order] ||=  "ascend_by_reported_at"
    @search = Report.search(params[:search])
    @reports = @search.paginate(:page => params[:page], :conditions => {:host_id => @host}, :include => :host)
  end

  def query
    if @verbose
      @hosts.map! do |host|
        hash = {}
        h = Host.find_by_name host
        hash[host] = h.info
        facts = {}
        h.fact_values.each {|fv| facts[fv.fact_name.name] = fv.value}
        hash[host]["facts"]= facts
        hash
      end
    end
    respond_to do |format|
      format.html
      format.yml { render :text => @hosts.to_yaml }
    end
  end

  def facts
    @host = Host.find(params[:id])
  end

  def storeconfig_klasses
    @host = Host.find(params[:id])
  end

  # multiple host selection methods

  # present the available actions to the user
  def multiple_actions
  end

  def multiple_parameters
    @parameters = Parameter.find(:all, :select => "DISTINCT name", :conditions => {:host_id => @hosts })
  end

  def reset_multiple
    session[:selected] = []
    flash[:foreman_notice] = 'Selection cleared.'
    redirect_to hosts_path and return
  end

  def update_multiple_parameters
    if params[:name].empty?
      flash[:foreman_notice] = "No parameters were allocted to the selected hosts, can't mass assign."
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
      flash[:foreman_notice] = 'Updated all hosts!'
      redirect_to(hosts_path) and return
    else
      flash[:foreman_notice] = "#{counter} Parameters updated, see below for more information"
    end
  end

  def select_multiple_hostgroup
  end

  def update_multiple_hostgroup
    # simple validations
    if (id=params["hostgroup"]["id"]).empty?
      flash[:foreman_error] = 'No Hostgroup selected!'
      redirect_to(select_multiple_hostgroup_hosts) and return
    end
    if (hg = Hostgroup.find id).nil?
      flash[:foreman_error] = 'Empty Hostgroup selected!'
      redirect_to(select_multiple_hostgroup_hosts) and return
    end

    #update the hosts
    Host.find(session[:selected]).each do |host|
      host.hostgroup=hg
      host.save(perform_validation = false)
    end

    session[:selected] = []
    flash[:foreman_notice] = 'Updated hosts: Changed Hostgroup'
    redirect_to(hosts_path)
  end

  def select_multiple_environment
  end

  def update_multiple_environment
    # simple validations
    if (id=params["environment"]["id"]).empty?
      flash[:foreman_error] = 'No Environment selected!'
      redirect_to(select_multiple_environment_hosts_path) and return
    end
    if (ev = Environment.find id).nil?
      flash[:foreman_error] = 'Empty Environment selected!'
      redirect_to(select_multiple_environment_hosts_path) and return
    end

    #update the hosts
    Host.find(session[:selected]).each do |host|
      host.environment=ev
      host.save(perform_validation = false)
    end

    session[:selected] = []
    flash[:foreman_notice] = 'Updated hosts: Changed Environment'
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
    flash[:foreman_notice] = hosts.empty? ? "Destroyed selected hosts" : "The following hosts were not deleted: #{hosts.map(&:name).join('<br>')}"
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

    render :text => '404 Not Found', :status => 404 and return if @hosts.empty?
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
      flash[:foreman_error] = 'No Hosts selected'
      redirect_to(hosts_path)
    else
      @hosts = Host.find(session[:selected], :order => "hostgroup_id ASC")
    end
  end

  def toggle_hostmode mode=true
    # keep all the ones that were not disabled for notification.
    @hosts.delete_if { |host| host.update_attribute(:enabled, mode) }
    action = mode ? "enabled" : "disabled"

    session[:selected] = []
    flash[:foreman_notice] = @hosts.empty? ? "#{action.capitalize} selected hosts" : "The following hosts were not #{action}: #{hosts.map(&:name).join('<br>')}"
    redirect_to(hosts_path) and return
  end

end
