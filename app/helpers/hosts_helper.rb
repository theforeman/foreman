module HostsHelper
  include OperatingsystemsHelper
  include HostsAndHostgroupsHelper

  def last_report_column(record)
    time = record.last_report? ? time_ago_in_words(record.last_report.getlocal) +" ago": ""
    link_to_if_authorized(time,
                          hash_for_host_report_path(:host_id => record.to_param, :id => "last"),
                          last_report_tooltip(record))
  end

  def last_report_tooltip record
    opts = { :rel => "twipsy" }
    if @last_reports[record.id]
      opts.merge!( "data-original-title" => "View last report details")
    else
      opts.merge!(:disabled => true, :class => "disabled", :onclick => 'return false')
      opts.merge!("data-original-title" => "Report Already Deleted") unless record.last_report.nil?
    end
    opts
  end

  # method that reformat the hostname column by adding the status icons
  def name_column(record)
    if record.build
      style ="notice"
      label = "Pending Installation"
      short = "B"
    elsif record.respond_to?(:enabled) && !record.enabled
      label = "Alerts disabled"
      style = ""
      short = "D"
    elsif record.respond_to?(:last_report) && record.last_report.nil?
      label = "No reports"
      style = ""
      short = "N"
    elsif record.error?
      label = "Error"
      style = "important"
      short = "E"
    elsif record.no_report
      label = "Out of sync"
      style = "warning"
      short = "S"
    elsif record.changes?
      label = "Active"
      style = "notice"
      short = "A"
    else
      label = "No changes"
      style = "success"
      short = "O"
    end
    content_tag(:span, short, {:rel => "twipsy", :class => "label " + style, :"data-original-title" => label} ) +
      link_to(" " + record.shortname, host_path(record),{:rel=>"twipsy", :"data-original-title"=>record})
  end

  def days_ago time
    ((Time.now - time) / 1.day).round.to_i
  end

  def authorized?
    authorized_for(:hosts, :edit) or authorized_for(:hosts, :destroy)
  end

  def searching?
    params[:search].empty?
  end

  def multiple_actions_select
    actions = [
      ['Select Actions', ''],
      ['Change Group', select_multiple_hostgroup_hosts_path],
      ['Change Environment', select_multiple_environment_hosts_path],
      ['Edit Parameters', multiple_parameters_hosts_path],
      ['Delete Hosts', multiple_destroy_hosts_path],
      ['Disable Notifications', multiple_disable_hosts_path],
      ['Enable Notifications', multiple_enable_hosts_path],
    ]
    actions.insert(1, ['Build Hosts', multiple_build_hosts_path]) if SETTINGS[:unattended]

    select_tag "Multiple Actions", options_for_select(actions), :id => "Submit_multiple", :"data-controls-modal"=>"confirmation-modal",
      :"data-backdrop"=>"static", :class => "medium", :title => "Perform Actions on multiple hosts"
  end

  def date ts=nil
    return "#{time_ago_in_words ts} ago" if ts
    "N/A"
  end

  def template_path opts = {}
    if t = @host.configTemplate(opts)
      link_to t, edit_config_template_path(t)
    else
      "N/A"
    end
  end

  def selected? host
    return false if host.nil? or not host.is_a?(Host) or session[:selected].nil?
    session[:selected].include?(host.id.to_s)
  end

  def update_details_from_hostgroup
    return nil unless @host.new_record?
    remote_function(:url => { :action => "process_hostgroup" },
                    :method => :post, :loading => "$('#indicator1').show()",
                    :complete => "$('#indicator1').hide()",
                    :with => "'hostgroup_id=' + value")
  end

  def report_status_chart name, title, subtitle, data, options = {}
    content_tag(:div, nil,
                { :id             => name,
                  :class          => 'span11 host_chart',
                  :'chart-name'   => name,
                  :'chart-title'  => title,
                  :'chart-subtitle'  => subtitle,
                  :'chart-data-failed'  => data[:failed].to_a.to_json,
                  :'chart-data-failed_restart'   => data[:failed_restart].to_a.to_json,
                  :'chart-data-skipped'  => data[:skipped].to_a.to_json,
                  :'chart-data-applied'  => data[:applied].to_a.to_json,
                  :'chart-data-restarted'  => data[:restarted].to_a.to_json
    }.merge(options))
  end

  def runtime_chart name, title, subtitle, data, options = {}
    content_tag(:div, nil,
                { :id             => name,
                  :class          => 'span11 host_chart',
                  :'chart-name'   => name,
                  :'chart-title'  => title,
                  :'chart-subtitle'  => subtitle,
                  :'chart-data-runtime'  => data[:runtime].to_a.to_json,
                  :'chart-data-config'   => data[:config].to_a.to_json
    }.merge(options))
  end

  def reports_show
    return unless @host.reports.size > 0
    form_tag @host, :id => 'days_filter', :method => :get do
      content_tag(:p, {}) { "Reports from the last " +
        select(nil, 'range', 1..days_ago(@host.reports.first.reported_at),
               {:selected => @range}, {:class=>"span2", :onchange =>"$('#days_filter').submit();$(this).disabled();"}) +
               " days - #{@host.reports.recent(@range.days.ago).count} reports found"
      }
    end
  end

  def name_field host
    (SETTINGS[:unattended] and host.managed?) ? host.shortname : host.name
  end

end
