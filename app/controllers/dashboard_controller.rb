class DashboardController < ApplicationController
  before_filter :conditions
  helper :hosts

  def index
    @total_hosts = Host.count
    # hosts with errors in the last puppet run
    @bad_hosts = Host.recent.with_error.count
    # hosts with changes in the last puppet run
    @active_hosts = Host.recent.with_changes.count
    @good_hosts = Host.recent.successful.count
    if @good_hosts == 0 or @total_hosts == 0
      @percentage = 0
    else
      @percentage = @good_hosts *100 / @total_hosts
    end
    # all hosts with didn't run puppet in the <time interval> - regardless of their status
    @out_of_sync_hosts = Host.out_of_sync.count
    @intersting_reports = Report.with_changes.count
    # the run interval to show in the dashboard graph
    @puppet_runs = Report.count_puppet_runs(@interval = 3)
  end

  def errors
    render :partial => "hosts/minilist", :layout => true, :locals => {
      :hosts => Host.recent.with_error,
      :header => "Hosts with errors" }
  end

  def active
    render :partial => "hosts/minilist", :layout => true, :locals => {
      :hosts => Host.recent.with_changes,
      :header => "Active Hosts" }
  end

  def OutOfSync
    render :partial => "hosts/minilist", :layout => true, :locals => {
      :hosts => Host.out_of_sync,
      :header => "Hosts which didnt run puppet in the last 30 minutes" }
  end

  private
  def conditions
    @report_conditions = "status != 0"
  end

end
