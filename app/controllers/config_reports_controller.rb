class ConfigReportsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :setup_search_options, :only => :index

  def index
    report_authorized = resource_base.my_reports
    @config_reports = report_authorized.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page], :per_page => params[:per_page]).includes(:host)
  end

  def show
    # are we searching for the last report?
    if params[:id] == "last"
      conditions = { :host_id => Host.find(params[:host_id]).try(:id) } unless params[:host_id].blank?
      params[:id] = resource_base.where(conditions).maximum(:id)
    end

    return not_found if params[:id].blank?

    @config_report = resource_base.includes(:logs => [:message, :source]).find(params[:id])
    @offset = @config_report.reported_at - @config_report.created_at
  end

  def destroy
    @config_report = resource_base.find(params[:id])
    if @config_report.destroy
      process_success :success_msg => _("Successfully deleted report."), :success_redirect => reports_path
    else
      process_error
    end
  end
end
