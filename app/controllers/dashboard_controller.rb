class DashboardController < ApplicationController
  before_filter :prefetch_data, :graphs, :only => :index
  before_filter :load_tabs, :manage_tabs, :only => [:errors, :OutOfSync, :active]
  helper :hosts

  def index
  end

  def errors
    @search = Host.recent.with_error.search(params[:search])
    respond_to do |format|
      format.html {
      hosts = @search.paginate :page => params[:page]
      @last_reports = Report.maximum(:id, :group => :host_id, :conditions => {:host_id => hosts})
         render :partial => "hosts/minilist", :layout => true, :locals => {
                :hosts => hosts,
                :header => "Hosts with errors" }
      }
      format.yml { render :text => @search.map(&:name).to_yaml }
    end
  end

  def active
    @search = Host.recent.with_changes.search(params[:search])
    respond_to do |format|
      format.html {
      hosts = @search.paginate :page => params[:page]
      @last_reports = Report.maximum(:id, :group => :host_id, :conditions => {:host_id => hosts})
         render :partial => "hosts/minilist", :layout => true, :locals => {
                :hosts => hosts,
                :header => "Active Hosts" }
      }
      format.yml { render :text => @search.map(&:name).to_yaml }
    end

  end

  def OutOfSync
    @search = Host.out_of_sync.search(params[:search])
    respond_to do |format|
      format.html {
      hosts = @search.paginate :page => params[:page]
      @last_reports = Report.maximum(:id, :group => :host_id, :conditions => {:host_id => hosts})
         render :partial => "hosts/minilist", :layout => true, :locals => {
                :hosts => hosts,
                :header => "Hosts which didn't run puppet in the last #{SETTINGS[:puppet_interval]} minutes" }
      }
      format.yml { render :text => @search.map(&:name).to_yaml }
    end
  end

  private
  def graphs

	@gdata = {}
	@gdata["OK"] = @good_hosts || 0
	@gdata["Active"] = @active_hosts || 0
	@gdata["Error"] = @bad_hosts || 0
	@gdata["Out of Sync"] = @out_of_sync_hosts || 0

    data = {
      :labels => [ ['datetime', "Time Ago In Minutes" ],['number', "Number Of Clients"]],
      :values => Report.count_puppet_runs()
    }

    	@run_distribution = {}
	@run_distribution["values"] = []
	@run_distribution["legends"] = []
	Report.count_puppet_runs.each { |run|
	@run_distribution["legends"] << "\"#{run.first}\""
	@run_distribution["values"] << run.last
	}
	@title = "Run Distribution in the last #{SETTINGS[:puppet_interval]} minutes"
  end

  def prefetch_data

    @total_hosts = Host.count
    # hosts with errors in the last puppet run
    @bad_hosts = Host.recent.with_error.count
    # hosts with changes in the last puppet run
    @active_hosts = Host.recent.with_changes.count
    @good_hosts = Host.recent.successful.count

    @percentage = (@good_hosts == 0 or @total_hosts == 0) ? 0 : @good_hosts *100 / @total_hosts

    # all hosts with didn't run puppet in the <time interval> - regardless of their status
    @out_of_sync_hosts = Host.out_of_sync.count
    @intersting_reports = Report.with_changes.count
    # the run interval to show in the dashboard graph
  end

end
