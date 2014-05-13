class DashboardController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :prefetch_data, :only => :index

  def index
    respond_to do |format|
      format.html
      format.yaml { render :text => @report.to_yaml }
      format.json
    end
  end

  private

  def prefetch_data
    dashboard = Dashboard::Data.new(params[:search])
    @hosts    = dashboard.hosts
    @report   = dashboard.report
  end

end
