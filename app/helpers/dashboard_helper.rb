module DashboardHelper

  def count_reports(hosts)
    interval = Setting[:puppet_interval] / 10
    counter = []
    labels = []
    start =Time.now.utc - Setting[:puppet_interval].minutes
    (1..(Setting[:puppet_interval] / interval)).each do
      now = start + interval.minutes
      counter <<  hosts.run_distribution(start, now-1.second).count
      minutes = (((start.getlocal-Time.now).abs)/60).round
      labels  <<  n_("%s minute ago", "%s minutes ago", minutes) % minutes
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
    pie_chart 'overview', _('Puppet Clients Activity Overview'), data, options
  end

  def render_run_distribution data, options = {}
    bar_chart "run_distribution",
              _("Run Distribution in the last %s Minutes") % Setting[:puppet_interval],
              _("Number Of Clients"),
              data[:labels],
              data[:counter],
              options
  end

  def searchable_links name, search
    search += " and #{params[:search]}" unless params[:search].blank?
    link_to name, hosts_path(:search => search)
  end

end
