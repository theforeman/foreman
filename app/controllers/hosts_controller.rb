class HostsController < ApplicationController
  before_filter :require_login, :except => [ :query, :externalNodes ]
  before_filter :require_ssl, :except => [ :query, :externalNodes ]
  before_filter :find_hosts, :only => :query

  helper :hosts

  active_scaffold :host do |config|
    list.empty_field_text ='N/A'
    list.per_page = 15
    list.sorting = {:name => 'ASC' }
    config.actions.exclude :show
    config.list.columns = [:name, :operatingsystem, :environment, :last_report ]
    config.columns = %w{ name hostgroup puppetclasses environment domain puppetmaster comment host_parameters}
    config.columns[:hostgroup].form_ui  = :select
    config.columns[:domain].form_ui  = :select
    config.columns[:environment].form_ui  = :select
    config.columns[:puppetclasses].form_ui  = :select
    config.columns[:puppetclasses].options = { :draggable_lists => {}}
    config.columns[:fact_values].association.reverse = :host
    config.nested.add_link("Inventory", [:fact_values])
    config.columns[:puppetmaster].description = "leave empty if it is #{SETTINGS[:puppet_server] || "puppet"}"
    # do not show these fields if unattended mode is disabled
    if SETTINGS[:unattended].nil? or SETTINGS[:unattended]
      config.columns = %w{ name ip mac hostgroup puppetclasses operatingsystem environment architecture media domain model root_pass serial puppetmaster ptable disk comment host_parameters}
      config.columns[:architecture].form_ui  = :select
      config.columns[:operatingsystem].form_ui  = :select
      config.columns[:operatingsystem].options = { :update_column => :media }
      config.columns[:media].form_ui  = :select
      config.columns[:model].form_ui  = :select
      config.columns[:ptable].form_ui  = :select
      config.columns[:serial].description = "unsed for now"
      config.columns[:disk].description = "the disk layout to use"
      config.columns[:build].form_ui  = :checkbox
      config.action_links.add 'setBuild', :label => 'Build', :inline => false,
        :type => :record, :confirm => "This actions recreates all needed settings for host installation, if the host is
         already running, it will disable certain functions.\n
         Are you sure you want to reinstall this host?"
    end
    config.action_links.add 'rrdreport', :label => 'RRDReport', :inline => true,
      :type => :record,  :position => :after if SETTINGS[:rrd_report_url]
    config.action_links.add 'externalNodes', :label => 'YAML', :inline => true,
      :type => :record, :position => :after
    config.action_links.add 'puppetrun', :label => 'Run', :inline => true,
      :type => :record, :position => :after if SETTINGS[:puppetrun]
  end

  def show
    # filter graph time range
    @range = (params["range"].empty? ? 1 : params["range"].to_i)
    range = @range.days.ago

    @host = Host.find params[:id]
    @report_summary = Report.summarise(range, @host)
    @graph = @host.graph(range)
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
    redirect_to :controller => "reports", :action => "show", :id => Host.find(params[:id]).reports.last
  end

  # shows all reports for a certian host
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
      q = f.split("-")
      invalid_request unless q.size == 2
      list = Host.with_fact(*q).send(state).map(&:name)
      @hosts = counter == 0 ? list : @hosts & list
      counter +=1
    end unless fact.nil?

    klass.each do |k|
      list = Host.recent.with_class(k).send(state).map(&:name)
      @hosts = counter == 0 ? list : @hosts & list
      counter +=1
    end unless klass.nil?

    render :text => '404 Not Found', :status => 404 and return if @hosts.empty?
  end

  def invalid_request
      render :text => 'Invalid query', :status => 400 and return
  end

end
