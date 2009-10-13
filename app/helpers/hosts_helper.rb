module HostsHelper
  def last_report_column(record)
    if record.last_report.nil? or record.reports.count == 0
      return "N/A"
    else
      time = time_ago_in_words(record.last_report.getlocal)
      image_tag("#{not (record.error_count > 0 or record.no_report)}.png", :size => "18x18") +
        link_to(time, report_host_path(record))
    end
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
      link_to(record.shortname, edit_host_url(record))
  end

  def disk_form_column(record, field_name)
    text_area_tag :record, :disk, :cols => 120, :rows => 10
  end

  def comment_form_column(record, field_name)
    text_area_tag :record, :comment, :cols => 120, :rows => 10
  end


end
