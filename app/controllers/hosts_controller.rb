class HostsController < ApplicationController
  before_filter :find_hosts, :only => :query

  helper :hosts

  active_scaffold :host do |config|
    list.empty_field_text ='N/A'
    list.per_page = 15
    list.sorting = {:name => 'ASC' }
    config.actions.exclude :show
    config.list.columns = [:name, :operatingsystem, :environment, :last_report ]
    config.columns = %w{ name ip mac hostgroup puppetclasses operatingsystem environment architecture media domain model root_pass serial puppetmaster ptable disk comment host_parameters}
    config.columns[:architecture].form_ui  = :select
    config.columns[:media].form_ui  = :select
    config.columns[:hostgroup].form_ui  = :select
    config.columns[:model].form_ui  = :select
    config.columns[:domain].form_ui  = :select
    config.columns[:puppetclasses].form_ui  = :select
    config.columns[:environment].form_ui  = :select
    config.columns[:ptable].form_ui  = :select
    config.columns[:operatingsystem].form_ui  = :select
    config.columns[:fact_values].association.reverse = :host
    config.nested.add_link("Inventory", [:fact_values])
    config.columns[:serial].description = "unsed for now"
    config.columns[:puppetmaster].description = "leave empty if its just puppet"
    config.columns[:disk].description = "the disk layout to use"
    config.columns[:build].form_ui  = :checkbox
    config.action_links.add 'rrdreport', :label => 'RRDReport', :inline => true,
        :type => :record if $settings[:rrd_report_url]
    config.action_links.add 'externalNodes', :label => 'YAML', :inline => true,
      :type => :record
    config.action_links.add 'setBuild', :label => 'Build', :inline => false,
      :type => :record, :confirm => "This actions recreates all needed settings for host installation, if the host is
         already running, it will disable certain functions.\n
         Are you sure you want to reinstall this host?"
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
    if $settings[:rrd_report_url].nil? or (host=Host.find(params[:id])).last_report.nil?
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

  private
  def find_hosts
    if (klass=params[:class]).empty? and (fact=params[:fact]).empty?
      render :text => '404 Not Found', :status => 404 and return
    end
    @hosts = (
      Host.find(:all, :select => "hosts.name", :joins => :puppetclasses,
                :conditions => ["puppetclasses.name = ?", klass]).map(&:name) +
      Host.find(:all, :select => :name, :joins => :fact_values,
                :conditions => ["fact_values.value = ?", fact]).map(&:name)
    ).uniq
    render :text => '404 Not Found', :status => 404 and return if @hosts.count == 0
  end


end
