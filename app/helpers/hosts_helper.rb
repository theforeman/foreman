module HostsHelper
  include CommonParametersHelper
  include OperatingsystemsHelper
  include HostsAndHostgroupsHelper

  def last_report_column(record)
    return nil if record.last_report.nil?
    time = time_ago_in_words(record.last_report.getlocal)
    image_tag("#{not (record.error_count > 0 or record.no_report)}.png", :size => "18x18") +
      link_to_if_authorized(time,  hash_for_host_report_path(:host_id => record.to_param, :id => "last", :enable_link => @last_reports[record.id]))
  end

# method that reformats the hostname column by adding the status icons
  def name_column(record)
    if record.build and not record.installed_at.nil?
      image ="attention_required.png"
      title = "Pending Installation"
    elsif (os = @fact_kernels.select{|h| h.host_id == record.id}.first.value rescue nil).nil?
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

  def select_hypervisor
    options_for_select Hypervisor.all.map{|h| [h.name, h.id]}, @host.try(:hypervisor_id).try(:to_i)
  end


  def select_memory memory = nil
    options_for_select Hypervisor::MEMORY_SIZE.map {|mem| [number_to_human_size(mem*1024), mem]}, memory.to_i
  end

  def accessible_domains
    (User.current.domains.any? and !User.current.admin?) ? User.current.domains : Domain.all
  end

  def accessible_hostgroups
    (User.current.hostgroups.any? and !User.current.admin?) ? User.current.hostgroups : Hostgroup.all
  end

  def update_details_from_hostgroup
    return nil unless @host.new_record?
    remote_function(:url => { :action => "process_hostgroup" },
                    :method => :post, :loading => "$('#indicator1').show()",
                    :complete => "$('#indicator1').hide()",
                    :with => "'hostgroup_id=' + value")
  end
end
