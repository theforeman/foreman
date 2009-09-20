module ReportsHelper

  def reported_at_column(record)
    if record.error?
      img = "hosts/warning"
    elsif record.changes?
      img = "hosts/attention_required"
    else
      img = "true"
    end
    image_tag("#{img}.png") + " " +
      time_ago_in_words(record.reported_at.getlocal)
  end
end
