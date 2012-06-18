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
      style ="label-info"
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
    elsif record.no_report
      label = "Out of sync"
      style = "label-warning"
      short = "S"
    elsif record.error?
      label = "Error"
      style = "label-important"
      short = "E"
    elsif record.changes?
      label = "Active"
      style = "label-info"
      short = "A"
    elsif record.pending?
      label = "Pending"
      style = "label-warning"
      short = "P"
    else
      label = "No changes"
      style = "label-success"
      short = "O"
    end
    content_tag(:span, short, {:rel => "twipsy", :class => "label " + style, :"data-original-title" => label} ) +
      link_to(trunc("  #{record}",32), host_path(record))
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
    actions <<  ['Run Puppet', multiple_puppetrun_hosts_path] if Setting[:puppetrun]

    select_tag "Multiple Actions", options_for_select(actions), :id => "Submit_multiple",
      :class => "medium", :title => "Perform Actions on multiple hosts"
  end

  def date ts=nil
    return "#{time_ago_in_words ts} ago" if ts
    "N/A"
  end

  def template_path opts = {}
    if (t = @host.configTemplate(opts))
      link_to t, edit_config_template_path(t)
    else
      "N/A"
    end
  end

  def selected? host
    return false if host.nil? or not host.is_a?(Host) or session[:selected].nil?
    session[:selected].include?(host.id.to_s)
  end

  def report_status_chart name, title, subtitle, data, options = {}
    content_tag(:div, nil,
                { :id             => name,
                  :class          => 'host_chart',
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
                  :class          => 'host_chart',
                  :'chart-name'   => name,
                  :'chart-title'  => title,
                  :'chart-subtitle'  => subtitle,
                  :'chart-data-runtime'  => data[:runtime].to_a.to_json,
                  :'chart-data-config'   => data[:config].to_a.to_json
                }.merge(options))
  end

  def reports_show
    return unless @host.reports.size > 0
    form_tag @host, :id => 'days_filter', :method => :get, :class=>"form form-inline" do
      content_tag(:span, "Reports from the last ") +
      select(nil, 'range', 1..days_ago(@host.reports.first.reported_at),
            {:selected => @range}, {:class=>"span1", :onchange =>"$('#days_filter').submit();$(this).disabled();"}).html_safe +
            " days - #{@host.reports.recent(@range.days.ago).count} reports found"
    end
  end

  def name_field host
    (SETTINGS[:unattended] and host.managed?) ? host.shortname : host.name
  end

  def show_templates
     unless SETTINGS[:unattended] and @host.managed?
       return content_tag(:div, :class =>"alert") do
         "Provisioning Support is disabled or this host is not managed"
       end
     end
    templates = TemplateKind.all.map{|k| @host.configTemplate(:kind => k.name)}.compact
    return "No Template found" if templates.empty?
    content_tag :table, :class=>"table table-bordered table-striped" do
      content_tag(:th, "Template Type") + content_tag(:th) +
      templates.sort{|t,x| t.template_kind <=> x.template_kind}.map do |tmplt|
        content_tag :tr do
          content_tag(:td, "#{tmplt.template_kind} Template") +
            content_tag(:td,
          link_to_if_authorized(icon_text('pencil'), hash_for_edit_config_template_path(:id => tmplt.to_param), :title => "Edit", :rel=>"external") +
          link_to(icon_text('eye-open'), url_for(:controller => 'unattended', :action => tmplt.template_kind.name, :spoof => @host.ip), :title => "Review", :"data-provisioning-template" => true ))
        end
      end.join(" ").html_safe
    end
  end

  def overview_fields host
    fields = [
      ["Domain", host.domain],
      ["IP Address", host.ip],
      ["MAC Address", host.mac],
      ["Puppet Environment", host.environment],
      ["Host Architecture", host.arch],
      ["Operating System", host.os],
      ["Host Group", host.hostgroup],
    ]
    fields += [["Owner", host.owner]] if SETTINGS[:login]
    fields += [["Certificate Name", host.certname]] if Setting[:use_uuid_for_certificates]
    fields
  end

  def possible_images cr, arch = nil, os = nil
    return cr.images unless controller_name == "hosts"
    return [] unless arch && os
    cr.images.where(:architecture_id => arch, :operatingsystem_id => os)
  end


  def host_title_actions(host, vm)
    title_actions(
        button_group(
            link_to_if_authorized("Edit", hash_for_edit_host_path(:id => host), :title => "Edit your host"),
            if host.build
              link_to_if_authorized("Cancel Build", hash_for_cancelBuild_host_path(:id => host), :disabled => host.can_be_build?,
                                    :title                                                                 => "Cancel build request for this host")
            else
              link_to_if_authorized("Build", hash_for_setBuild_host_path(:id => host), :disabled => !host.can_be_build?,
                                    :title                                                       => "Enable rebuild on next host boot",
                                    :confirm                                                     => "Rebuild #{host} on next reboot?\nThis would also delete all of its current facts and reports")
            end
        ),
        if host.compute_resource_id
          button_group(
              if vm
                html_opts = vm.ready? ? {:confirm => 'Are you sure?', :class => "btn btn-danger"} : {:class => "btn btn-success"}
                link_to_if_authorized "Power#{state(vm.ready?)}", hash_for_power_host_path(:power_action => vm.ready? ? :stop : :start), html_opts.merge(:method => :put)
              else
                link_to("Unknown Power State", '#', :disabled => true, :class => "btn btn-warning")
              end +
                  link_to_if_authorized("Console", hash_for_console_host_path(), {:disabled => vm.nil? || !vm.ready?, :class => "btn btn-info"})
          )
        end,
        button_group(
            link_to_if_authorized("Run puppet", hash_for_puppetrun_host_path(:id => host).merge(:auth_action => :edit),
                                  :disabled => !Setting[:puppetrun],
                                  :title => "Trigger a puppetrun on a node; requires that puppet run is enabled"),
            link_to_if_authorized("All Puppet Classes", hash_for_storeconfig_klasses_host_path(:id => host).merge(:auth_action => :read),
                                  :disabled => host.resources.count == 0,
                                  :title => "Show all host puppet classes, requires storeconfigs")
        ),
        button_group(
            link_to_if_authorized("Delete", hash_for_host_path(:id => host, :auth_action => :destroy),
                                  :class => "btn btn-danger", :confirm => 'Are you sure?', :method => :delete)
        )
    )
  end
end
