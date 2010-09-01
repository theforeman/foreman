module ReportsHelper

  def reported_at_column(record)
    if record.error?
      img = "hosts/warning"
    elsif record.changes?
      img = "hosts/attention_required"
    else
      img = "true"
    end
    image_tag("#{img}.png", :size => "18x18") + " " +
      link_to(time_ago_in_words(record.reported_at.getlocal) + " ago", report_path(record))
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
end
