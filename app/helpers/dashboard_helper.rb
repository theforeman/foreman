module DashboardHelper
  def add_to_dashboard(widget)
    button_to(_('Add to dashboard'), widgets_path(:widget => widget), :method => :post)
  end

  def dashboard_actions
    [
      content_tag(:span, (_("Generated at %s") % date_time_absolute(Time.zone.now)).html_safe),
      select_action_button(
        _('Manage'), {},
        link_to_function(_('Save positions'), "tfm.dashboard.savePosition('#{save_positions_widgets_path}')"),
        link_to(_('Reset to default'), reset_default_widgets_path, :method => :put),
        content_tag(:li, '', :class => 'divider'),
        content_tag(:h6, _("Add widgets"), :class => 'dropdown-header'),
        content_tag(:li, '', :class => 'widget-add') do
          widgets_to_add
        end
      ),
      auto_refresh_button(:defaults_to => false),
      documentation_button,
    ]
  end

  def removed_widgets
    user_widgets = User.current.widgets.pluck(:name)
    Dashboard::Manager.default_widgets.reject do |widget|
      user_widgets.include?(widget[:name])
    end
  end

  def widgets_to_add
    return link_to(_('Nothing to add'), '#') unless removed_widgets.present?
    removed_widgets.sort_by { |w| w[:name] }.each do |removed_widget|
      concat(link_to_function(_(removed_widget[:name]),
        "tfm.dashboard.addWidget('#{removed_widget[:name]}')"))
    end
  end

  def widget_data(widget)
    { :data => { :id    => widget.id,    :name  => _(widget.name), :row => widget.row, :col => widget.col,
                 :sizex => widget.sizex, :sizey =>  widget.sizey } }
  end

  def count_reports(hosts, options = {})
    data = []
    interval_setting = report_origin_interval_setting(options[:origin])
    interval = interval_setting / 10
    start = Time.zone.now - interval_setting.minutes
    (0..9).each do |i|
      t = start + (interval.minutes * i)
      data << [interval_setting - i * interval, hosts.run_distribution(t, t + interval.minutes).count]
    end
    data
  end

  def get_overview(report, options = {})
    options[:origin] = nil if options[:origin] == 'All'

    state_labels = {
      active_hosts_ok_enabled: _('Active'),
      bad_hosts_enabled: _('Error'),
      ok_hosts_enabled: _('OK'),
      pending_hosts_enabled: _('Pending changes'),
      out_of_sync_hosts_enabled: _('Out of sync'),
      reports_missing: _('No report'),
      disabled_hosts: _('Disabled alerts'),
    }
    state_filters = {
      active_hosts_ok_enabled: '(status.applied > 0 or status.restarted > 0) and (status.failed = 0)',
      bad_hosts_enabled: '(status.failed > 0 or status.failed_restarts > 0) and status.enabled = true',
      ok_hosts_enabled: 'status.enabled = true and status.applied = 0 and status.failed = 0 and status.pending = 0',
      pending_hosts_enabled: 'status.pending > 0 and status.enabled = true',
      out_of_sync_hosts_enabled: 'status.enabled = true',
      reports_missing: 'not has last_report and status.enabled = true',
      disabled_hosts: 'status.enabled = false',
    }
    ignore_interval = [:reports_missing, :disabled_hosts]
    within_interval = ignore_interval + [:out_of_sync_hosts_enabled]

    {
      data: state_labels.map { |key, label| [label, report[key], report_color[key]] },
      searchUrl: hosts_path(search: '~VAL~'),
      searchFilters: state_filters.each_with_object({}) do |(key, filter), filters|
        filters[state_labels[key]] = search_filter_with_origin(filter, options[:origin], within_interval.include?(key), ignore_interval.include?(key))
      end,
    }
  end

  def get_run_distribution_data(hosts, options = {})
    data = count_reports(hosts, options).to_a
    data.map { |label, value| [label.to_s, value] }
  end

  def translated_header(shortname, longname)
    "<th class='ca'><span class='small' title='' data-original-title='#{longname}'>#{shortname}</span></th>"
  end

  def latest_headers
    string =  "<th>#{_('Host')}</th>"
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
      :disabled_hosts => "#92A8CD",
    }
  end

  def auto_refresh_button(options = {})
    on = options[:defaults_to] ? "on" : "off"
    if params[:auto_refresh].present?
      on = (params[:auto_refresh] == "0") ? "off" : "on"
    end
    if on == "on"
      tooltip = _("Auto refresh on")
    else
      tooltip = _("Auto refresh off")
    end
    link_to(icon_text("refresh"),
      {:auto_refresh => ((on == "on") ? "0" : "1")},
      { :'data-original-title' => tooltip, :rel => 'twipsy', :class => "#{on} auto-refresh btn btn-group btn-default"})
  end

  def widget_class_name(widget)
    settings = widget.data[:settings]
    if settings && settings[:class_name]
      settings[:class_name]
    else
      widget.name
    end
  end

  def search_filter_with_origin(filter, origin, within_interval = false, ignore_interval = false)
    interval_setting = report_origin_interval_setting(origin)
    additional_filters = []
    additional_filters << "origin = #{origin}" if origin
    additional_filters << "last_report #{within_interval ? '<' : '>'} \"#{interval_setting} minutes ago\"" if out_of_sync_enabled?(origin) && !ignore_interval
    (additional_filters + [filter]).join(' and ')
  end

  def report_origin_interval_setting(origin)
    if origin && origin != 'All'
      interval_setting = origin_setting(origin, 'interval')
    end
    interval_setting ||= Setting[:outofsync_interval]
    interval_setting.to_i
  end

  def out_of_sync_enabled?(origin)
    setting = origin_setting(origin, 'out_of_sync_disabled')
    setting.nil? ? true : !setting
  end

  def host_build_status_icon(host)
    if host.token_expired?
      icon = 'hourglass-o'
      icon_kind = 'fa'
      icon_class = 'text-danger'
      label = _('Token expired')
    elsif host.build_errors.present?
      icon = 'error-circle-o'
      icon_kind = 'pficon'
      icon_class = ''
      label = _('Build errors')
    else
      icon = 'in-progress'
      icon_kind = 'pficon'
      icon_class = ''
      label = _('Build in progress')
    end
    icon_text(icon, '', kind: icon_kind, title: label, class: icon_class)
  end

  private

  def origin_setting(origin, name)
    return nil unless origin
    Setting[:"#{origin.downcase}_#{name}"]
  end
end
