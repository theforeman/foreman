require 'ostruct'
module ReportsHelper

  def reported_at_column(record)
    link_to(time_ago_in_words(record.reported_at.getlocal) + " ago", report_path(record))
  end

   def report_event_column(event, style = "")
    style = "" if event == 0
    content_tag(:span, event, :class=>'label ' + style)
  end

  def reports_since builder
    choices = [30,60,90].map{|i| OpenStruct.new :name => "#{i} minutes ago", :value => i.minutes.ago }
    choices += (1..7).map{|i| OpenStruct.new :name => "#{pluralize(i, 'day')} ago", :value => i.days.ago }
    choices += [OpenStruct.new(:name => "1 week ago",   :value =>  1.week.ago)]
    choices += [OpenStruct.new(:name => "2 weeks ago",  :value =>  2.week.ago)]
    choices += [OpenStruct.new(:name => "1 month ago",  :value =>  1.month.ago)]
    choices += [OpenStruct.new(:name => "3 months ago", :value =>  3.month.ago)]
    choices += [OpenStruct.new(:name => "All Reports", :value =>  Report.first(:select => "created_at").created_at)]
    builder.collection_select :reported_at_gt, choices, :value, :name, {:include_blank => "Select a period"}
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
    "class='label label-#{tag}'"
  end

   def logs_show
    return unless @report.logs.size > 0
    form_tag @report, :id => 'level_filter', :method => :get do
      content_tag(:span, "Show log messages: ") +
      select(nil, 'level', [['All messages', 'notice'],['Warnings and errors', 'warning'],['Errors only', 'error']],
             {}, {:class=>"span3", :onchange =>"filter_by_level(this);"})
    end
   end
end
