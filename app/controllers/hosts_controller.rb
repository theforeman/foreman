class HostsController < ApplicationController
  before_filter :require_login, :except => [ :query, :externalNodes, :lookup ]
  before_filter :require_ssl, :except => [ :query, :externalNodes, :lookup ]
  before_filter :find_hosts, :only => :query
  before_filter :ajax_methods, :only => [:environment_selected, :architecture_selected, :os_selected]
  before_filter :load_tabs, :manage_tabs, :only => :index

  helper :hosts

  def index
    @search = Host.search(params[:search])
    @hosts = @search.paginate :page => params[:page]
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
    # Clone any parameters as well
    @original.host_parameters.each{|param| @host.host_parameters << param.clone}
    flash[:error_customisation] = {:header_message => nil, :class => "flash notice", :id => nil,
      :message => "The following fields will need modification:" }
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
      render :text => "Successfully executed, check log files for more details"
    else
      render :text => "Failed, check log files"
    end
  end

  def setBuild
    host = Host.find params[:id]
    if host.setBuild != false
      flash[:foreman_notice] = "Enabled #{host.name} for installation boot away"
    else
      flash[:foreman_error] = "Failed to enable #{host.name} for installation"
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
  end

  def query
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

  private
  def find_hosts
    fact, klass = params[:fact], params[:class]
    if fact.empty? and klass.empty?
      render :text => '404 Not Found', :status => 404 and return
    end

    @hosts = []
    counter = 0

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

end
