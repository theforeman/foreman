class ReportsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :setup_search_options, :only => :index

  def index
    @reports = Report.my_reports.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page], :per_page => params[:per_page]).includes(:host)
  rescue => e
    error e.to_s
    @reports = Report.my_reports.search_for("").paginate :page => params[:page]
  end

  def show
    # are we searching for the last report?
    if params[:id] == "last"
      conditions = { :host_id => Host.find_by_name(params[:host_id]).try(:id) } unless params[:host_id].blank?
      params[:id] = Report.my_reports.maximum(:id, :conditions => conditions)
    end

    return not_found if params[:id].blank?

    @report = Report.my_reports.find(params[:id], :include => { :logs => [:message, :source] })
    @offset = @report.reported_at - @report.created_at
  end

  def destroy
    @report = Report.find(params[:id])
    if @report.destroy
      notice _("Successfully destroyed report.")
    else
      error @report.errors.full_messages.join("<br/>")
    end
    redirect_to reports_url
  end

end
