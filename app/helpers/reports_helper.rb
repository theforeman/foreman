require 'ostruct'
module ReportsHelper
  def reported_at_column(record)
    link_to config_report_path(record) do
      date_time_relative(record.reported_at)
    end
  end

  def report_event_column(event, style = "")
    style = "label-default" if event == 0
    content_tag(:span, event, :class => 'label ' + style)
  end

  def reports_since(builder)
    choices = [30, 60, 90].map { |i| OpenStruct.new :name => n_("%s minute ago", "%s minutes ago", i) % i, :value => i.minutes.ago }
    choices += (1..7).map { |i| OpenStruct.new :name => n_("%s day ago", "%s days ago", i) % i, :value => i.days.ago }
    choices += (1..3).map { |i| OpenStruct.new :name => n_("%s week ago", "%s weeks ago", i) % i, :value => i.week.ago }
    choices += (1..3).map { |i| OpenStruct.new :name => n_("%s month ago", "%s months ago", i) % i, :value => i.month.ago }
    choices += [OpenStruct.new(:name => _("All Reports"), :value => Report.first(:select => "created_at").created_at)]
    builder.collection_select :reported_at_gt, choices, :value, :name, {:include_blank => _("Select a period")}
  end

  def metric(m)
    m.round(4) rescue _("N/A")
  end

  def metrics_table_data(metrics)
    metrics.each do |title, value|
      metrics[title] = metric value
    end
    metrics.sort_by { |lable, value| value }.reverse
  end

  def report_tag(level)
    tag = case level
          when :notice
            "info"
          when :warning
            "warning"
          when :err
            "danger"
          else
            "default"
          end
    "class='label label-#{tag} result-filter-tag'".html_safe
  end

  def logs_show
    return if @config_report.logs.empty?
    form_tag config_report_path(@config_report), :id => 'level_filter', :method => :get, :class => "form form-horizontal" do
      content_tag(:span, _("Show log messages:") + ' ') +
      select(nil, 'level', [[_('All messages'), 'info'], [_('Notices, warnings and errors'), 'notice'], [_('Warnings and errors'), 'warning'], [_('Errors only'), 'error']],
        {}, {:class => "col-md-1 form-control", :onchange => "filter_by_level(this);"})
    end
  end

  def report_origin_icon(origin)
    return 'N/A' if origin.blank?
    origin_icon = try("#{origin.downcase}_report_origin_icon".to_sym)
    image_tag(origin_icon || origin + ".png", :title => _("Reported by %s") % origin)
  end

  def report_origin_output_partial(origin)
    return report_default_partial if origin.blank?
    origin_partial = try("#{origin.downcase}_report_origin_partial".to_sym)
    origin_partial || report_default_partial
  end

  def report_default_partial
    'output'.freeze
  end

  def config_report_content(log)
    message = log.message.to_s
    if message.start_with?("\n---")
      filename = log.source.value.to_s.scan(/File\[(.*?)\]/).flatten.first rescue ""
      return link_to(_('Show Diff'), '#', data: {diff: message, title: filename}, onclick: 'tfm.configReportsModalDiff.showDiff(this);')
    end
    message
  end
end
