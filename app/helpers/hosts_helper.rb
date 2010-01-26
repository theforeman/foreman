module HostsHelper
  def last_report_column(record)
    return nil if record.last_report.nil?
    time = time_ago_in_words(record.last_report.getlocal)
    image_tag("#{not (record.error_count > 0 or record.no_report)}.png", :size => "18x18") +
      link_to_if(record.reports.last, time, report_host_path(record))
  end

  def root_pass_form_column(record, field_name)
      password_field_tag field_name, record.root_pass
  end

# method that reformats the hostname column by adding the status icons
  def name_column(record)
    if record.build and not record.installed_at.nil?
      image ="attention_required.png"
      title = "Pending Installation"
    elsif (os=record.fv(:kernel)).nil?
      image = "warning.png"
      title = "No Inventory Data"
    else
      image = "#{os}.jpg"
      title = os
    end
    image_tag("hosts/#{image}", :size => "18x18", :title => title) +
      link_to(record.shortname, host_path(record))
  end

  def disk_form_column(record, field_name)
    text_area_tag field_name, record.disk, :cols => 120, :rows => 10
  end

  def comment_form_column(record, field_name)
    text_area_tag field_name, record.comment, :cols => 120, :rows => 10
  end

  def options_for_association_conditions(association)
    case association.name
    when :media
      {'medias.operatingsystem_id' => @record.operatingsystem_id}
    when :ptable
      {'ptables.operatingsystem_id' => @record.operatingsystem_id}
    else
      super
    end
  end

  def days_ago time
    ((Time.now - time) / 1.day).round.to_i
  end

end
