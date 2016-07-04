module HostsGlobalStatusHelper
  def host_global_status_icon_class_for_host(host)
    options = {}
    options[:last_reports] = @last_reports unless @last_reports.nil?
    host_global_status_icon_class(host.build_global_status(options).status)
  end

  def host_global_status_icon_class(status)
    icon_class = case status
                 when HostStatus::Global::OK
                   'pficon-ok'
                 when HostStatus::Global::WARN
                   'pficon-info'
                 when HostStatus::Global::ERROR
                   'pficon-error-circle-o'
                 else
                   'pficon-help'
                 end

    "host-status #{icon_class} #{host_global_status_class(status)}"
  end

  def host_global_status_class(status)
    case status
      when HostStatus::Global::OK
        'status-ok'
      when HostStatus::Global::WARN
        'status-warn'
      when HostStatus::Global::ERROR
        'status-error'
      else
        'status-question'
    end
  end

  def host_detailed_status_list(host)
    host.host_statuses.sort_by(&:type).map do |status|
      next unless status.relevant?
      [
        _(status.name),
        content_tag(:span, ' '.html_safe, :class => host_global_status_icon_class(status.to_global)) +
          content_tag(:span, _(status.to_label), :class => host_global_status_class(status.to_global))
      ]
    end.compact
  end
end
