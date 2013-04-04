module DashboardHelper

  def count_reports(hosts)
    data = []
    interval = Setting[:puppet_interval] / 10
    start = Time.now.utc - Setting[:puppet_interval].minutes
    (0..9).each do |i|
      t = start + (interval.minutes * i)
      data << [Setting[:puppet_interval] - i*interval , hosts.run_distribution(t, t + interval.minutes).count]
    end
    data
  end

  def render_overview report, options = {}
    data = [{:label=>'Active', :data => report[:active_hosts_ok_enabled],:color => "#4572A7"},
            {:label=>'Error', :data =>report[:bad_hosts_enabled], :color => "#AA4643"},
            {:label=>'OK', :data =>report[:ok_hosts_enabled],:color => "#89A54E"},
        {:label=>'Pending changes', :data =>report[:pending_hosts_enabled],:color => "#80699B"},
        {:label=>'Out of sync', :data =>report[:out_of_sync_hosts_enabled],:color => "#3D96AE"},
        {:label=>'No report', :data =>report[:reports_missing],:color => "#DB843D"},
        {:label=>'Notification disabled', :data =>report[:disabled_hosts],:color => "#92A8CD"}]
    flot_pie_chart 'overview', 'Host Configuration Status', data, options
  end

  def render_run_distribution hosts, options = {}
    data = count_reports(hosts)
    flot_bar_chart("run_distribution", "Minutes Ago", "Number Of Clients", data, options)
  end

  def searchable_links name, search
    search += " and #{params[:search]}" unless params[:search].blank?
    link_to name, hosts_path(:search => search),:class=>"dashboard-links"
  end

end