class ReportsController < ApplicationController
  before_filter :require_login, :except => :create
  before_filter :verify_authenticity_token, :except => :create
  helper :reports

  # avoids storing the report data in the log files
  filter_parameter_logging :report

  active_scaffold :reports do |config|
    config.label   = "Puppet reports"
    config.actions = [:list, :search, :delete]
    config.columns = [:host, :reported_at, :failed, :failed_restarts, :skipped, :config_retrival, :runtime]
    config.list.sorting   = { :reported_at => :desc }
    config.action_links.add 'show', :label => 'Details', :inline => false, :type => :record
    config.action_links.add 'expire_reports', :label => 'Expire Reports Older than 24Hours', :inline => false, :type => :table
  end

  def create
    respond_to do |format|
      format.yml {
        if Report.import params.delete("report")
          render :text => "Imported report", :status => 200 and return
        else
          render :text => "Failed to import report", :status => 500
        end
      }
    end
  end

  def show
    @report = Report.find(params[:id])
  end

  def expire_reports
    redirect_to :back
    flash[:foreman_notice] = "Deleted #{Report.expire_reports} reports"
  end

end
