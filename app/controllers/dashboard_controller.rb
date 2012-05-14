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
    @hosts = Host.search_for(params[:search])
    @report = {
      :total_hosts               => @hosts.count,
      :bad_hosts                 => @hosts.recent.with_error.count,
      :bad_hosts_enabled         => @hosts.recent.with_error.alerts_enabled.count,
      :active_hosts              => @hosts.recent.with_changes.count,
      :active_hosts_ok           => @hosts.recent.with_changes.without_error.count,
      :active_hosts_ok_enabled   => @hosts.recent.with_changes.without_error.alerts_enabled.count,
      :ok_hosts                  => @hosts.recent.successful.count,
      :ok_hosts_enabled          => @hosts.recent.successful.alerts_enabled.count,
      :out_of_sync_hosts         => @hosts.out_of_sync.count,
      :out_of_sync_hosts_enabled => @hosts.out_of_sync.alerts_enabled.count,
      :disabled_hosts            => @hosts.alerts_disabled.count,
      :pending_hosts             => @hosts.recent.with_pending_changes.count,
      :pending_hosts_enabled     => @hosts.recent.with_pending_changes.alerts_enabled.count,
    }
    @report[:good_hosts] = @report[:ok_hosts] + @report[:active_hosts_ok]
    @report[:good_hosts_enabled] = @report[:ok_hosts_enabled] + @report[:active_hosts_ok_enabled]
    @report[:percentage] = (@report[:good_hosts] == 0 or @report[:total_hosts] == 0) ? 0 : @report[:good_hosts]*100 / @report[:total_hosts]
    @report[:reports_missing] = @report[:total_hosts] - @report[:good_hosts_enabled] - @report[:bad_hosts_enabled] - @report[:out_of_sync_hosts_enabled] - @report[:pending_hosts_enabled] - @report[:disabled_hosts]
  end

end
