module DashboardHelper
  def add_to_dashboard(widget)
    button_to(_('Add to dashboard'), widgets_path(:widget => widget), :method => :post)
  end

  def dashboard_actions
    [
      _("Generated at %s") % Time.zone.now.to_s(:short),
      select_action_button(
        _('Manage'), {},
        link_to_function(_('Save dashboard'), "save_position('#{save_positions_widgets_path}')"),
        link_to(_('Reset to default'), reset_default_widgets_path, :method => :put),
        content_tag(:li, '', :class=>'divider'),
        content_tag(:li, _("Restore widgets"), :class=>'nav-header', :id=>'restore_list'),
        content_tag(:li, '', :class=>'divider'),
        content_tag(:li, _("Add widgets"), :class=>'nav-header'),
        content_tag(:li, '', :class=>'widget-add') do
          widgets_to_add
        end
      ),
      documentation_button,
      auto_refresh_button(:defaults_to => true)
    ]
  end

  def removed_widgets
    Dashboard::Manager.default_widgets - User.current.widgets.map(&:to_hash)
  end

  def widgets_to_add
    return link_to(_('Nothing to add'), '#') unless removed_widgets.present?
    removed_widgets.each do |removed_widget|
      concat(link_to_function(_(removed_widget[:name]),
                              "add_widget('#{removed_widget[:name]}')"))
    end
  end

  def render_widget(widget)
    render(:partial => widget.template, :locals => widget.data)
  rescue ActionView::MissingTemplate
    ::Foreman::Exception.new(N_("Missing template '%{template}' for widget '%{widget}'."), :widget => _(widget.name), :template => widget.template)
  end

  def widget_data(widget)
    { :data => { :id    => widget.id,    :name  => _(widget.name), :row  => widget.row, :col => widget.col,
                 :sizex => widget.sizex, :sizey =>  widget.sizey,  :hide => widget.hide } }
  end

  def count_reports(hosts)
    data = []
    interval = Setting[:puppet_interval] / 10
    start = Time.zone.now - Setting[:puppet_interval].minutes
    (0..9).each do |i|
      t = start + (interval.minutes * i)
      data << [Setting[:puppet_interval] - i*interval, hosts.run_distribution(t, t + interval.minutes).count]
    end
    data
  end

  def render_overview(report, options = {})
    data = [{:label=>_('Active'), :data => report[:active_hosts_ok_enabled],:color => report_color[:active_hosts_ok_enabled]},
            {:label=>_('Error'), :data =>report[:bad_hosts_enabled], :color => report_color[:bad_hosts_enabled]},
            {:label=>_('OK'), :data =>report[:ok_hosts_enabled],:color => report_color[:ok_hosts_enabled]},
            {:label=>_('Pending changes'), :data =>report[:pending_hosts_enabled],:color => report_color[:pending_hosts_enabled]},
            {:label=>_('Out of sync'), :data =>report[:out_of_sync_hosts_enabled],:color => report_color[:out_of_sync_hosts_enabled]},
            {:label=>_('No report'), :data =>report[:reports_missing],:color => report_color[:reports_missing]},
            {:label=>_('Notification disabled'), :data =>report[:disabled_hosts],:color => report_color[:disabled_hosts]}]
    flot_pie_chart 'overview', _('Host Configuration Status'), data, options.merge(:search => "search_by_legend")
  end

  def render_run_distribution(hosts, options = {})
    data = count_reports(hosts)
    flot_bar_chart("run_distribution", _("Minutes Ago"), _("Number Of Clients"), data, options)
  end

  def searchable_links(name, search, counter)
    search += " and #{params[:search]}" unless params[:search].blank?
    content_tag :li do
      content_tag(:i, raw('&nbsp;'), :class=>'label', :style => "background-color:" + report_color[counter]) +
      raw('&nbsp;')+
      link_to(name, hosts_path(:search => search),:class=>"dashboard-links") +
      content_tag(:h4,@report[counter])
    end
  end

  def latest_events
    # 6 reports + header fits the events box nicely...
    Report.authorized(:view_config_reports).my_reports.interesting.search_for('reported > "7 days ago"').limit(6).includes(:host)
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

  def report_color
    {
      :active_hosts_ok_enabled => "#4572A7",
      :bad_hosts_enabled => "#AA4643",
      :ok_hosts_enabled => "#89A54E",
      :pending_hosts_enabled => "#80699B",
      :out_of_sync_hosts_enabled => "#3D96AE",
      :reports_missing => "#DB843D",
      :disabled_hosts => "#92A8CD"
    }
  end

  def auto_refresh_button(options = {})
    on = options[:defaults_to] ? "on" : "off"
    if params[:auto_refresh].present?
      on = params[:auto_refresh] == "0" ? "off" : "on"
    end
    if on == "on"
      tooltip = _("Auto refresh on")
    else
      tooltip = _("Auto refresh off")
    end
    link = link_to(icon_text("refresh"), {:auto_refresh => (on == "on" ? "0" : "1")}, { :'data-original-title' => tooltip, :rel => 'twipsy' })
    "<div class='btn-toolbar pull-right auto-refresh #{on}'>#{link}</div>"
  end
end
