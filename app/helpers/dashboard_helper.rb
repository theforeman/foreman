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
    data = [[:Active,    report[:active_hosts]],
            [:Error, report[:bad_hosts]],
            [:OK, report[:ok_hosts]],
            [:'Pending changes', report[:pending_hosts]],
            [:'Out of sync', report[:out_of_sync_hosts]],
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
end
