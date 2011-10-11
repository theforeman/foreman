class DashboardController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :prefetch_data, :only => :index

  def index
    respond_to do |format|
      format.html
      format.yaml { render :text => @report.to_yaml }
      format.json { render :json => @report }
    end

  end

  private
  def prefetch_data
    hosts = Host.search_for(params[:search])
    @report = {
      :total_hosts => hosts.count,
      :bad_hosts => hosts.recent.with_error.count,
      :active_hosts => hosts.recent.with_changes.count,
      :good_hosts => hosts.recent.successful.count,
      :out_of_sync_hosts => hosts.out_of_sync.count,
      :disabled_hosts => hosts.alerts_disabled.count
    }
    @report[:percentage] = (@report[:good_hosts] == 0 or @report[:total_hosts] == 0) ? 0 : @report[:good_hosts]*100 / @report[:total_hosts]
  end

end
