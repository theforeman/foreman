require 'ostruct'
module ReportsHelper

  def reported_at_column(record)
    link_to(_("%s ago") % time_ago_in_words(record.reported_at.getlocal), report_path(record))
  end

   def report_event_column(event, style = "")
    style = "" if event == 0
    content_tag(:span, event, :class=>'label ' + style)
  end

  def reports_since builder
    choices = [30,60,90].map{|i| OpenStruct.new :name => n_("%s minute ago", "%s minutes ago", i) % i, :value => i.minutes.ago }
    choices += (1..7).map{|i| OpenStruct.new :name => n_("%s day ago", "%s days ago", i) % i, :value => i.days.ago }
    choices += (1..3).map{|i| OpenStruct.new :name => n_("%s week ago", "%s weeks ago", i) % i, :value => i.week.ago }
    choices += (1..3).map{|i| OpenStruct.new :name => n_("%s month ago", "%s months ago", i) % i, :value => i.month.ago }
    choices += [OpenStruct.new(:name => _("All Reports"), :value =>  Report.first(:select => "created_at").created_at)]
    builder.collection_select :reported_at_gt, choices, :value, :name, {:include_blank => _("Select a period")}
  end

  def metric m
    m.round(4) rescue "N/A"
  end

  def report_tag level
    tag = case level
          when :notice
            "info"
          when :warning
            "warning"
          when :err
            "important"
          else
            "default"
          end
    "class='label label-#{tag}'".html_safe
  end

   def logs_show
    return unless @report.logs.size > 0
    form_tag @report, :id => 'level_filter', :method => :get do
      content_tag(:span, _("Show log messages:") + ' ') +
      select(nil, 'level', [[_('All messages'), 'notice'],[_('Warnings and errors'), 'warning'],[_('Errors only'), 'error']],
             {}, {:class => "input-medium", :onchange =>"filter_by_level(this);"})
    end
   end
end
