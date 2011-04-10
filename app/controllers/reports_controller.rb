class ReportsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  skip_before_filter :require_login,             :only => :create
  skip_before_filter :require_ssl,               :only => :create
  skip_before_filter :authorize,                 :only => :create
  skip_before_filter :verify_authenticity_token, :only => :create
  before_filter :set_admin_user, :only => :create

  # avoids storing the report data in the log files
  filter_parameter_logging :report

  def index
    @reports = Report.search_for(params[:search], :order => params[:order]).paginate :page => params[:page]
    flash.clear
  rescue => e
    error e.to_s
    @reports = Report.all.paginate :page => params[:page]
  end

  def show
    @report = Report.find(params[:id], :include => [:logs, :messages, :sources])
    @offset = @report.reported_at - @report.created_at
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
  rescue => e
    render :text => e.to_s, :status => 500
  end

  def destroy
    @report = Report.find(params[:id])
    if @report.destroy
      notice "Successfully destroyed report."
    else
      error @report.errors.full_messages.join("<br/>")
    end
    redirect_to reports_url
  end
end
