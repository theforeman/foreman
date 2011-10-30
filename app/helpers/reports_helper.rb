require 'ostruct'
module ReportsHelper

  def report_icon(record)
    if record.error? or record.no_report
      img = "hosts/warning"
    elsif record.changes?
      img = "hosts/attention_required"
    else
      img = "true"
    end
    image_tag("#{img}.png", :size => "18x18")
  end

  def reported_at_column(record)
    report_icon(record) + " " + link_to(time_ago_in_words(record.reported_at.getlocal) + " ago", report_path(record))
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
    h(m.round_with_precision(4)) rescue "N/A"
  end

  def report_tag level
    tag = case level
          when :notice
            "notice"
          when :warning
            "warning"
          when :err
            "important"
          else
            "default"
          end
    "class='label #{tag}'"
  end

   def logs_show
    return unless @report.logs.size > 0
    form_tag @report, :id => 'level_filter', :method => :get do
      content_tag(:p, {}) { "Show logs with severity higher or equal to " +
        select(nil, 'level', {:notice => 0,:warning => 1,:err => 2},
               {:selected => params[:level].to_i}, {:class=>"span2", :onchange =>"$('#level_filter').submit();$(this).disabled();"})
      }
    end
   end

   def logs_filter(level)
     return true unless params[:level]
     return case level
          when :notice
            params[:level].to_i <= 0;
          when :warning
            params[:level].to_i <= 1;
          when :err
            params[:level].to_i <= 2;
          else
            true
          end
   end
end
