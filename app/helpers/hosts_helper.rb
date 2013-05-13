module HostsHelper
  include OperatingsystemsHelper
  include HostsAndHostgroupsHelper
  include ComputeResourcesVmsHelper
  include BmcHelper

  def last_report_column(record)
    time = record.last_report? ? _("%s ago") % time_ago_in_words(record.last_report.getlocal): ""
    link_to_if_authorized(time,
                          hash_for_host_report_path(:host_id => record.to_param, :id => "last"),
                          last_report_tooltip(record))
  end

  def last_report_tooltip record
    opts = { :rel => "twipsy" }
    if @last_reports[record.id]
      opts.merge!( "data-original-title" => _("View last report details"))
    else
      opts.merge!(:disabled => true, :class => "disabled", :onclick => 'return false')
      opts.merge!("data-original-title" => _("Report Already Deleted")) unless record.last_report.nil?
    end
    opts
  end

  # method that reformat the hostname column by adding the status icons
  def name_column(record)
    label = record.host_status
    case label
    when "Pending Installation"
      style ="label-info"
      # TRANSLATORS: host's status: first character of "build"
      short = s_("Build|B")
    when "Alerts disabled"
      style = ""
      # TRANSLATORS: host's status: first character of "disabled"
      short = s_("Disabled|D")
    when "No reports"
      style = ""
      # TRANSLATORS: host's status: first character of "no reports"
      short = s_("No reports|N")
    when "Out of sync"
      style = "label-warning"
      # TRANSLATORS: host's status: first character of "sync" (out of sync)
      short = s_("Sync|S")
    when "Error"
      style = "label-important"
      # TRANSLATORS: host's status: first character of "error"
      short = s_("Error|E")
    when "Active"
      style = "label-info"
      # TRANSLATORS: host's status: first character of "active"
      short = s_("Active|A")
    when "Pending"
      style = "label-warning"
      # TRANSLATORS: host's status: first character of "pending"
      short = s_("Pending|P")
    else
      style = "label-success"
      # TRANSLATORS: host's status: first character of "OK"
      short = s_("OK|O")
    end
    content_tag(:span, short, {:rel => "twipsy", :class => "label label-light " + style, :"data-original-title" => _(label)} ) +
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
      [_('Change Group'), select_multiple_hostgroup_hosts_path, 'pencil'],
      [_('Change Environment'), select_multiple_environment_hosts_path, 'chevron-right'],
      [_('Edit Parameters'), multiple_parameters_hosts_path, 'edit'],
      [_('Delete Hosts'), multiple_destroy_hosts_path, 'trash'],
      [_('Disable Notifications'), multiple_disable_hosts_path, 'eye-close'],
      [_('Enable Notifications'), multiple_enable_hosts_path, 'bullhorn'],
    ]
    actions.insert(1, [_('Build Hosts'), multiple_build_hosts_path, 'fast-forward']) if SETTINGS[:unattended]
    actions <<  [_('Run Puppet'), multiple_puppetrun_hosts_path, 'play'] if Setting[:puppetrun]
    actions <<  [_('Assign Organization'), select_multiple_organization_hosts_path, 'tags'] if SETTINGS[:organizations_enabled]
    actions <<  [_('Assign Location'), select_multiple_location_hosts_path, 'map-marker'] if SETTINGS[:locations_enabled]

    content_tag :span, :id => 'submit_multiple' do
      select_action_button( _("Select Action"), actions.map do |action|
        link_to(icon_text(action[2], action[0]) , action[1], :class=>'btn',  :title => _("%s - The following hosts are about to be changed") % action[0])
      end.flatten)
    end

  end

  def date ts=nil
    return _("%s ago") % (time_ago_in_words ts) if ts
    _("N/A")
  end

  def template_path opts = {}
    if (t = @host.configTemplate(opts))
      link_to t, edit_config_template_path(t)
    else
      _("N/A")
    end
  end

  def selected? host
    return false if host.nil? or not host.kind_of?(Host::Base) or session[:selected].nil?
    session[:selected].include?(host.id.to_s)
  end

  def resources_chart(timerange = 1.day.ago)
    applied, failed, restarted, failed_restarts, skipped = [],[],[],[],[]
    @host.reports.recent(timerange).each do |r|
      applied         << [r.reported_at.to_i*1000, r.applied ]
      failed          << [r.reported_at.to_i*1000, r.failed ]
      restarted       << [r.reported_at.to_i*1000, r.restarted ]
      failed_restarts << [r.reported_at.to_i*1000, r.failed_restarts ]
      skipped         << [r.reported_at.to_i*1000, r.skipped ]
    end
    [{:label=>_("Applied"), :data=>applied,:color =>'#89A54E'},
     {:label=>_("Failed"), :data=>failed,:color =>'#AA4643'},
     {:label=>_("Failed restarts"), :data=>failed_restarts,:color =>'#AA4643'},
     {:label=>_("Skipped"), :data=>skipped,:color =>'#80699B'},
     {:label=>_("Restarted"), :data=>restarted,:color =>'#4572A7'}]
  end

  def runtime_chart(timerange = 1.day.ago)
    config, runtime = [], []
    @host.reports.recent(timerange).each do |r|
      config  << [r.reported_at.to_i*1000, r.config_retrieval]
      runtime << [r.reported_at.to_i*1000, r.runtime]
    end
    [{:label=>_("Config Retrieval"), :data=> config, :color=>'#AA4643'},{:label=>_("Runtime"), :data=> runtime,:color=>'#4572A7'}]
  end

  def reports_show
    return unless @host.reports.size > 0
    form_tag @host, :id => 'days_filter', :method => :get, :class=>"form form-inline" do
      content_tag(:span, (_("Reports from the last %{days} days - %{count} reports found") %
        { :days  => select(nil, 'range', 1..days_ago(@host.reports.first.reported_at),
                    {:selected => @range}, {:class=>"span1", :onchange =>"$('#days_filter').submit();$(this).disabled();"}),
          :count => @host.reports.recent(@range.days.ago).count }).html_safe)
    end
  end

  def name_field host
    return if host.name.blank?
    (SETTINGS[:unattended] and host.managed?) ? host.shortname : host.name
  end

  def show_templates
    unless SETTINGS[:unattended] and @host.managed?
      return content_tag(:div, :class =>"alert") do
        _("Provisioning Support is disabled or this host is not managed")
      end
    end
    begin
      templates = TemplateKind.all.map{|k| @host.configTemplate(:kind => k.name)}.compact
    rescue => e
      return case e.to_s
      when "Must provide an operating systems"
        _("Unable to find templates as this host has no operating system")
      else
        e.to_s
      end
    end

    return _("No template found") if templates.empty?
    content_tag :table, :class=>"table table-bordered table-striped" do
      content_tag(:th, _("Template Type")) + content_tag(:th) +
      templates.sort{|t,x| t.template_kind <=> x.template_kind}.map do |tmplt|
        content_tag :tr do
          content_tag(:td, _("%s Template") % tmplt.template_kind) +
            content_tag(:td,
          link_to_if_authorized(icon_text('pencil'), hash_for_edit_config_template_path(:id => tmplt.to_param), :title => _("Edit"), :rel=>"external") +
          link_to(icon_text('eye-open'), url_for(:controller => '/unattended', :action => tmplt.template_kind.name, :spoof => @host.ip), :title => _("Review"), :"data-provisioning-template" => true ))
        end
      end.join(" ").html_safe
    end
  end

  def overview_fields host
    fields = [
      [_("Domain"), (link_to(host.domain, hosts_path(:search => "domain = #{host.domain}")) if host.domain)],
      [_("IP Address"), host.ip],
      [_("MAC Address"), host.mac],
      [_("Puppet Environment"), (link_to(host.environment, hosts_path(:search => "environment = #{host.environment}")) if host.environment)],
      [_("Host Architecture"), (link_to(host.arch, hosts_path(:search => "architecture = #{host.arch}")) if host.arch)],
      [_("Operating System"), (link_to(host.os, hosts_path(:search => "os = #{host.os.name}")) if host.os)],
      [_("Host group"), (link_to(host.hostgroup, hosts_path(:search => "hostgroup = #{host.hostgroup}")) if host.hostgroup)],
    ]
    fields += [[_("Location"), (link_to(host.location.name, hosts_path(:search => "location = #{host.location}")) if host.location)]] if SETTINGS[:locations_enabled]
    fields += [[_("Organization"), (link_to(host.organization.name, hosts_path(:search => "organization = #{host.organization}")) if host.organization)]] if SETTINGS[:organizations_enabled]
    if SETTINGS[:login]
      if host.owner_type == _("User")
        fields += [[_("Owner"), (link_to(host.owner, hosts_path(:search => "user.login = #{host.owner.login}")) if host.owner)]]
      else
        fields += [[_("Owner"), host.owner]]
      end
    end
    fields += [[_("Certificate Name"), host.certname]] if Setting[:use_uuid_for_certificates]
    fields
  end

  def possible_images cr, arch = nil, os = nil
    return cr.images unless controller_name == "hosts"
    return [] unless arch && os
    cr.images.where(:architecture_id => arch, :operatingsystem_id => os)
  end

  def state s
    s ? ' ' + _("Off") : ' ' + _("On")
  end

  def host_title_actions(host, vm)
    title_actions(
        button_group(
            link_to_if_authorized(_("Edit"), hash_for_edit_host_path(:id => host), :title => _("Edit your host")),
            if host.build
              link_to_if_authorized(_("Cancel Build"), hash_for_cancelBuild_host_path(:id => host), :disabled => host.can_be_built?,
                                    :title                                                                 => _("Cancel build request for this host"))
            else
              link_to_if_authorized(_("Build"), hash_for_setBuild_host_path(:id => host), :disabled => !host.can_be_built?,
                                    :title                                                       => _("Enable rebuild on next host boot"),
                                    :confirm                                                     => _("Rebuild %s on next reboot?\nThis would also delete all of its current facts and reports") % host)
            end
        ),
        if host.compute_resource_id
          button_group(
              if vm
                html_opts = vm.ready? ? {:confirm => _('Are you sure?'), :class => "btn btn-danger"} : {:class => "btn btn-success"}
                link_to_if_authorized _("Power%s") % state(vm.ready?), hash_for_power_host_path(:power_action => vm.ready? ? :stop : :start), html_opts.merge(:method => :put)
              else
                link_to(_("Unknown Power State"), '#', :disabled => true, :class => "btn btn-warning")
              end +
                  link_to_if_authorized(_("Console"), hash_for_console_host_path(), {:disabled => vm.nil? || !vm.ready?, :class => "btn btn-info"})
          )
        end,
        button_group(
          if host.try(:puppet_proxy)
            link_to_if_authorized(_("Run puppet"), hash_for_puppetrun_host_path(:id => host).merge(:auth_action => :edit),
                                  :disabled => !Setting[:puppetrun],
                                  :title => _("Trigger a puppetrun on a node; requires that puppet run is enabled"))
          end
        ),
        button_group(
            link_to_if_authorized(_("Delete"), hash_for_host_path(:id => host, :auth_action => :destroy),
                                  :class => "btn btn-danger", :confirm => _('Are you sure?'), :method => :delete)
        )
    )
  end

  def conflict_objects errors
    errors.keys.map(&:to_s).grep(/conflict$/).map(&:to_sym)
  end

  def has_conflicts? errors
    conflict_objects(errors).each do |c|
      return true if errors[c.to_sym].any?
    end
    false
  end
end
