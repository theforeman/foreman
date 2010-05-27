module HostsHelper
  def last_report_column(record)
    return nil if record.last_report.nil?
    time = time_ago_in_words(record.last_report.getlocal)
    image_tag("#{not (record.error_count > 0 or record.no_report)}.png", :size => "18x18") +
      link_to_if(@last_reports[record.id], time, report_path(@last_reports[record.id].to_i))
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

  def days_ago time
    ((Time.now - time) / 1.day).round.to_i
  end

  def searching?
    params[:search].empty?
  end

  def selected? host
    return false if host.nil? or not host.is_a?(Host) or session[:selected].nil?
    session[:selected].include?(host.id.to_s)
  end

  def hosts_controller?
    controller.controller_name == "hosts"
  end

end
