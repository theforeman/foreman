class ReportsController < ApplicationController
  helper :reports

  active_scaffold :reports do |config|
    config.label   = "Puppet reports"
    config.actions = [:list, :search, :delete]
    config.columns = [:host, :reported_at, :failed, :failed_restarts, :skipped, :config_retrival, :runtime]
    config.list.sorting   = { :reported_at => :desc }
    config.action_links.add 'show', :label => 'Details', :inline => false, :type => :record
    config.action_links.add 'expire_reports', :label => 'Expire Reports Older than 24Hours', :inline => false, :type => :table
  end

  skip_before_filter :verify_authenticity_token

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
    Report.expire_reports
  end

end
