class DashboardController < ApplicationController
  before_filter :conditions

  def index
    @total_hosts = Host.count
    @good_hosts = Host.count(:all, :conditions => @good_reports)
    @out_of_sync_hosts = Host.count(:all, :conditions => @sync_conditions)
    @intersting_reports = Report.count(:all, :conditions => @report_conditions)
  end

  private
  def conditions
    time = Time.now.utc - 35.minutes
    @sync_conditions = ["last_report < ? or last_report is ?", time, nil]
    @report_conditions = "status > 0"
    @good_reports = ["last_report > ? and puppet_status = ?", time, 0]
  end

end

