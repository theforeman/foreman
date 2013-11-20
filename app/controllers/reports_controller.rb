class ReportsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :setup_search_options, :only => :index

  def index
    @reports = Report.authorized(:view_reports).my_reports.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page], :per_page => params[:per_page]).includes(:host)
    @authorizer = Authorizer.new(User.current, @reports)
  end

  def show
    # are we searching for the last report?
    if params[:id] == "last"
      conditions = { :host_id => Host.find_by_name(params[:host_id]).try(:id) } unless params[:host_id].blank?
      params[:id] = Report.authorized(:view_reports).where(conditions).maximum(:id)
    end

    return not_found if params[:id].blank?

    @report = Report.authorized(:view_reports).includes(:logs => [:message, :source]).find(params[:id])
    @offset = @report.reported_at - @report.created_at
  end

  def destroy
    @report = Report.authorized(:destroy_reports).find(params[:id])
    if @report.destroy
      notice _("Successfully destroyed report.")
    else
      error @report.errors.full_messages.join("<br/>")
    end
    redirect_to reports_url
  end

end
