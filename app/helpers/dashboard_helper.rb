module DashboardHelper

  def count_reports(systems)
    data = []
    interval = Setting[:puppet_interval] / 10
    start = Time.now.utc - Setting[:puppet_interval].minutes
    (0..9).each do |i|
      t = start + (interval.minutes * i)
      data << [Setting[:puppet_interval] - i*interval , systems.run_distribution(t, t + interval.minutes).count]
    end
    data
  end

  def render_overview report, options = {}
    data = [{:label=>_('Active'), :data => report[:active_systems_ok_enabled],:color => report_color[:active_systems_ok_enabled]},
            {:label=>_('Error'), :data =>report[:bad_systems_enabled], :color => report_color[:bad_systems_enabled]},
            {:label=>_('OK'), :data =>report[:ok_systems_enabled],:color => report_color[:ok_systems_enabled]},
            {:label=>_('Pending changes'), :data =>report[:pending_systems_enabled],:color => report_color[:pending_systems_enabled]},
            {:label=>_('Out of sync'), :data =>report[:out_of_sync_systems_enabled],:color => report_color[:out_of_sync_systems_enabled]},
            {:label=>_('No report'), :data =>report[:reports_missing],:color => report_color[:reports_missing]},
            {:label=>_('Notification disabled'), :data =>report[:disabled_systems],:color => report_color[:disabled_systems]}]
    flot_pie_chart 'overview', _('System Configuration Status'), data, options.merge(:search => "search_by_legend")
  end

  def render_run_distribution systems, options = {}
    data = count_reports(systems)
    flot_bar_chart("run_distribution", _("Minutes Ago"), _("Number Of Clients"), data, options)
  end

  def searchable_links name, search, counter
    search += " and #{params[:search]}" unless params[:search].blank?
    content_tag :li do
      content_tag(:i, raw('&nbsp;'), :class=>'label', :style => "background-color:" + report_color[counter]) +
      raw('&nbsp;')+
      link_to(name, systems_path(:search => search),:class=>"dashboard-links") +
      content_tag(:h4,@report[counter])
    end
  end

  def latest_events
    # 6 reports + header fits the events box nicely...
    summary = Report.my_reports.interesting.search_for('reported > "7 days ago"').limit(6)
  end

  def translated_header(shortname, longname)
    "<th><span class='small' title='' data-original-title='#{longname}'>#{shortname}</span></th>"
  end

  def latest_headers
    string =  "<th>#{_("System")}</th>"
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

  def report_color
    {
        :active_systems_ok_enabled => "#4572A7",
        :bad_systems_enabled => "#AA4643",
        :ok_systems_enabled => "#89A54E",
        :pending_systems_enabled => "#80699B",
        :out_of_sync_systems_enabled => "#3D96AE",
        :reports_missing => "#DB843D",
        :disabled_systems => "#92A8CD"
    }
  end

end
