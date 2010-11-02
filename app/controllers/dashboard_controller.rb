class DashboardController < ApplicationController
  before_filter :prefetch_data, :graphs, :only => :index
  skip_before_filter :load_tabs, :manage_tabs

  def index
    respond_to do |format|
      format.html
      format.yaml { render :text => @report.to_yaml }
      format.json { render :json => @report }
    end

  end

  private
  def graphs

    data ={
      :labels => [ ['string', "State"], ['number', "Number of Hosts"] ],
      :values => [
        ["Active", @report[:active_hosts]],["Error", @report[:bad_hosts]],
        ["Out Of Sync", @report[:out_of_sync_hosts]],  ["OK", @report[:good_hosts]]
      ]
    }
    options = { :title => "Puppet Clients Activity Overview"}
    @overview = setgraph(GoogleVisualr::PieChart.new, data, options)

    data = {
      :labels => [ ['datetime', "Time Ago In Minutes" ],['number', "Number Of Clients"]],
      :values => Report.count_puppet_runs()
    }
    options = { :title => "Run Distribution in the last #{SETTINGS[:puppet_interval]} minutes", :min => 0 }
    @run_distribution = setgraph(GoogleVisualr::ColumnChart.new, data, options)

  end

  def prefetch_data
    @report = {
      :total_hosts => Host.count,
      :bad_hosts => Host.recent.with_error.count,
      :active_hosts => Host.recent.with_changes.count,
      :good_hosts => Host.recent.successful.count,
      :out_of_sync_hosts => Host.out_of_sync.count,
      :disabled_hosts => Host.alerts_disabled.count
    }
    @report[:percentage] = (@report[:good_hosts] == 0 or @report[:total_hosts] == 0) ? 0 : @report[:good_hosts]*100 / @report[:total_hosts]
  end

end
