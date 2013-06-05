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
    data = [{:label=>_('Active'), :data => report[:active_hosts_ok_enabled],:color => "#4572A7"},
            {:label=>_('Error'), :data =>report[:bad_hosts_enabled], :color => "#AA4643"},
            {:label=>_('OK'), :data =>report[:ok_hosts_enabled],:color => "#89A54E"},
        {:label=>_('Pending changes'), :data =>report[:pending_hosts_enabled],:color => "#80699B"},
        {:label=>_('Out of sync'), :data =>report[:out_of_sync_hosts_enabled],:color => "#3D96AE"},
        {:label=>_('No report'), :data =>report[:reports_missing],:color => "#DB843D"},
        {:label=>_('Notification disabled'), :data =>report[:disabled_hosts],:color => "#92A8CD"}]
    flot_pie_chart 'overview', _('Host Configuration Status'), data, options
  end

  def render_run_distribution hosts, options = {}
    data = count_reports(hosts)
    flot_bar_chart("run_distribution", _("Minutes Ago"), _("Number Of Clients"), data, options)
  end

  def searchable_links name, search
    search += " and #{params[:search]}" unless params[:search].blank?
    link_to name, hosts_path(:search => search),:class=>"dashboard-links"
  end

  def latest_events
    # 6 reports + header fits the events box nicely...
    summary = Report.my_reports.interesting.search_for('reported > "7 days ago"').limit(6)
  end

  def translated_header(shortname, longname)
    "<th><span class='small' title='' data-original-title='#{longname}'>#{shortname}</span></th>"
  end

  def latest_headers
    string =  "<th>#{_("Host")}</th>"
    # TRANSLATORS: initial character of Applied
    string += translated_header(s_('Applied|A'), _('Applied'))
    # TRANSLATORS: initial character of Restarted
    string += translated_header(s_('Restarted|R'), _('Restarted'))
    # TRANSLATORS: initial character of Failed
    string += translated_header(s_('Failed|F'), _('Failed'))
    # TRANSLATORS: initial characters of Failed Restarts
    string += translated_header(s_('Failed Restarts|FR'), _('Failed Restarts'))
    # TRANSLATORS: initial character of Skipped
    string += translated_header(s_('Skipped|S'), _('Skipped'))
    # TRANSLATORS: initial character of Pending
    string += translated_header(s_('Pending|P'), _('Pending'))

    string.html_safe
  end

end
