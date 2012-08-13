module DashboardHelper

  def count_reports(hosts)
    interval = Setting[:puppet_interval] / 10
    counter = []
    labels = []
    start =Time.now.utc - Setting[:puppet_interval].minutes
    (1..(Setting[:puppet_interval] / interval)).each do
      now = start + interval.minutes
      counter <<  hosts.run_distribution(start, now-1.second).count
      labels  <<  "#{time_ago_in_words(start.getlocal)}"
      start = now
    end
    {:labels => labels, :counter =>counter}
  end

  def render_overview report, options = {}
    data = [[:Active,    report[:active_hosts_ok_enabled]],
            [:Error, report[:bad_hosts_enabled]],
            [:OK, report[:ok_hosts_enabled]],
            [:'Pending changes', report[:pending_hosts_enabled]],
            [:'Out of sync', report[:out_of_sync_hosts_enabled]],
            [:'No report', report[:reports_missing]],
            [:'Notification disabled', report[:disabled_hosts]]]
    pie_chart 'overview', 'Puppet Clients Activity Overview', data, options
  end

  def render_run_distribution data, options = {}
    bar_chart "run_distribution",
              "Run Distribution in the last #{Setting[:puppet_interval]} minutes",
              "Number Of Clients",
              data[:labels],
              data[:counter],
              options
  end

  def searchable_links name, search
    search += " and #{params[:search]}" unless params[:search].blank?
    link_to name, hosts_path(:search => search)
  end

  def prefetch_data
    @hosts  = Host.my_hosts.search_for(params[:search])
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
