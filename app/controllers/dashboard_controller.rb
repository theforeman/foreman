class DashboardController < ApplicationController
  before_filter :prefetch_data, :graphs, :only => :index
  skip_before_filter :load_tabs, :manage_tabs
  helper :hosts
  include Foreman::Controller::FactSelection

  def index
  end

  private
  def graphs

    data ={
      :labels => [ ['string', "State"], ['number', "Number of Hosts"] ],
      :values => [ ["Active", @active_hosts],["Error", @bad_hosts ],  ["Out Of Sync", @out_of_sync_hosts ],  ["OK", @good_hosts] ]
    }
    options = { :title => "Puppet Clients Activity Overview"}#,
#      :colors =>['#0000FF','#FF0000','#00FF00','#41A317'] }
    @overview = setgraph(GoogleVisualr::PieChart.new, data, options)

    data = {
      :labels => [ ['datetime', "Time Ago In Minutes" ],['number', "Number Of Clients"]],
      :values => Report.count_puppet_runs()
    }
    options = { :title => "Run Distribution in the last #{SETTINGS[:puppet_interval]} minutes", :min => 0 }
    @run_distribution = setgraph(GoogleVisualr::ColumnChart.new, data, options)

  end

  def prefetch_data

    @total_hosts = Host.count
    # hosts with errors in the last puppet run
    @bad_hosts = Host.recent.with_error.count
    # hosts with changes in the last puppet run
    @active_hosts = Host.recent.with_changes.count
    @good_hosts = Host.recent.successful.count

    @percentage = (@good_hosts == 0 or @total_hosts == 0) ? 0 : @good_hosts *100 / @total_hosts

    # all hosts with didn't run puppet in the <time interval> - regardless of their status
    @out_of_sync_hosts = Host.out_of_sync.count
    @intersting_reports = Report.with_changes.count
    @disabled_hosts = Host.alerts_disabled.count
    # the run interval to show in the dashboard graph
  end

end
