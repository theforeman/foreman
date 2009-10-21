module ReportsHelper

  def host_column(record)
    link_to record.host.shortname, reports_host_path(record.host)
  end

  def reported_at_column(record)
    if record.error?
      img = "hosts/warning"
    elsif record.changes?
      img = "hosts/attention_required"
    else
      img = "true"
    end
    image_tag("#{img}.png", :size => "18x18") + " " +
      link_to(time_ago_in_words(record.reported_at.getlocal), report_path(record))
  end
end
