class ReportsController < ApplicationController
  before_filter :require_login, :except => :create
  before_filter :require_ssl, :except => :create
  before_filter :verify_authenticity_token, :except => :create
  helper :reports

  # avoids storing the report data in the log files
  filter_parameter_logging :report

  def index
    search_cmd  = "Report"
    for condition in Report::METRIC
      search_cmd += ".with('#{condition.to_s}', #{params[condition]})" if params.has_key? condition
    end
    search_cmd += ".search(params[:search])"
    # set defaults search order - cant use default scope due to bug in AR
    # http://github.com/binarylogic/searchlogic/issues#issue/17
    params[:search] ||=  {}
    params[:search][:order] ||=  "ascend_by_reported_at"

    @search  = eval search_cmd
    @reports = @search.paginate :page => params[:page], :include => [{:host => :domain}]
  end

  def show
    @report = Report.find(params[:id])
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

  def destroy
    @report = Report.find(params[:id])
    if @report.destroy
      flash[:foreman_notice] = "Successfully destroyed report."
    else
      flash[:foreman_error] = @report.errors.full_messages.join("<br>")
    end
    redirect_to reports_url
  end
end
