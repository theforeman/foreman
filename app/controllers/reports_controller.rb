class ReportsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  skip_before_filter :require_login,             :only => :create
  skip_before_filter :require_ssl,               :only => :create
  skip_before_filter :authorize,                 :only => :create
  skip_before_filter :verify_authenticity_token, :only => :create
  skip_before_filter :session_expiry, :update_activity_time, :only => :create
  before_filter :set_admin_user, :only => :create
  before_filter :setup_search_options, :only => :index

  def index
    values = Report.my_reports.search_for(params[:search], :order => params[:order])
    pagination_opts = { :page => params[:page], :per_page => params[:per_page] }
    respond_to do |format|
      format.html { @reports =      values.paginate(pagination_opts).includes(:host) }
      format.json { render :json => values.paginate(pagination_opts).includes(:host, :logs)}
    end
  rescue => e
    error e.to_s
    @reports = Report.my_reports.search_for("").paginate :page => params[:page]
  end

  def show
    # are we searching for the last report?
    if params[:id] == "last"
      conditions = { :host_id => Host.find_by_name(params[:host_id]).try(:id) } unless params[:host_id].blank?
      params[:id] = Report.maximum(:id, :conditions => conditions)
    end

    return not_found if params[:id].blank?

    @report = Report.my_reports.find(params[:id], :include => { :logs => [:message, :source] })
    respond_to do |format|
      format.html { @offset = @report.reported_at - @report.created_at }
      format.json { render :json => @report }
    end
  end

  def create
    if Report.import params.delete("report") || request.body
      render :text => "Imported report", :status => 200 and return
    else
      render :text => "Failed to import report", :status => 500
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
