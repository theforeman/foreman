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
      style = "label-default"
      # TRANSLATORS: host's status: first character of "disabled"
      short = s_("Disabled|D")
    when "No reports"
      style = "label-default"
      # TRANSLATORS: host's status: first character of "no reports"
      short = s_("No reports|N")
    when "Out of sync"
      style = "label-warning"
      # TRANSLATORS: host's status: first character of "sync" (out of sync)
      short = s_("Sync|S")
    when "Error"
      style = "label-danger"
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
      link_to(trunc("  #{record}"), host_path(record))
  end

  def days_ago time
    ((Time.now - time) / 1.day).round.to_i
  end

  def authorized?
    authorized_for(:controller => :hosts, :action => :edit) or
        authorized_for(:controller => :hosts, :action => :destroy)
  end

  def searching?
    params[:search].empty?
  end

  def multiple_actions_select
    actions = [
      [_('Change Group'), select_multiple_hostgroup_hosts_path],
      [_('Change Environment'), select_multiple_environment_hosts_path],
      [_('Edit Parameters'), multiple_parameters_hosts_path],
      [_('Delete Hosts'), multiple_destroy_hosts_path],
      [_('Disable Notifications'), multiple_disable_hosts_path],
      [_('Enable Notifications'), multiple_enable_hosts_path],
      [_('Disassociate Hosts'), multiple_disassociate_hosts_path],
    ]
    actions.insert(1, [_('Build Hosts'), multiple_build_hosts_path]) if SETTINGS[:unattended]
    actions <<  [_('Run Puppet'), multiple_puppetrun_hosts_path] if Setting[:puppetrun]
    actions <<  [_('Assign Organization'), select_multiple_organization_hosts_path] if SETTINGS[:organizations_enabled]
    actions <<  [_('Assign Location'), select_multiple_location_hosts_path] if SETTINGS[:locations_enabled]

      select_action_button( _("Select Action"), {:id => 'submit_multiple'},
        actions.map do |action|
          link_to(action[0] , action[1], :'data-dialog-title' => _("%s - The following hosts are about to be changed") % action[0])
        end.flatten
      )
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
    form_tag @host, :id => 'days_filter', :method => :get, :class => "form form-inline" do
      content_tag(:span, (_("Reports from the last %{days} days - %{count} reports found") %
        { :days  => select(nil, 'range', 1..days_ago(@host.reports.first.reported_at),
                    {:selected => @range}, {:class=>"col-md-1 form-control", :style=>"float:none;", :onchange =>"$('#days_filter').submit();$(this).disabled();"}),
          :count => @host.reports.recent(@range.days.ago).count }).html_safe)
    end
  end

  def name_field host
    return if host.name.blank?
    (SETTINGS[:unattended] and host.managed?) ? host.shortname : host.name
  end

  def show_templates
    unless SETTINGS[:unattended] and @host.managed?
      return content_tag(:div, :class =>"alert alert-warning") do
        _("Provisioning Support is disabled or this host is not managed")
      end
    end
    begin
      templates = Hash[TemplateKind.order(:name).map do |k|
        template = @host.configTemplate(:kind => k.name)
        next if template.nil?
        [k.name, template]
      end.compact]
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
      templates.map do |kind, tmplt|
        content_tag :tr do
          content_tag(:td, _("%s Template") % kind) +
            content_tag(:td,
                        action_buttons(
                            display_link_if_authorized(_("Edit"), hash_for_edit_config_template_path(:id => tmplt.to_param), :rel=>"external"),
                            link_to(_("Review"), url_for(:controller => '/unattended', :action => kind, :hostname => @host.name), :"data-provisioning-template" => true ))
            )
        end
      end.join(" ").html_safe
    end
  end

  def overview_fields host
    fields = [
      [_("Domain"), (link_to(host.domain, hosts_path(:search => "domain = #{host.domain}")) if host.domain)],
      [_("Realm"), (link_to(host.realm, hosts_path(:search => "realm = #{host.realm}")) if host.realm)],
      [_("IP Address"), host.ip],
      [_("MAC Address"), host.mac],
      [_("Puppet Environment"), (link_to(host.environment, hosts_path(:search => "environment = #{host.environment}")) if host.environment)],
      [_("Host Architecture"), (link_to(host.arch, hosts_path(:search => "architecture = #{host.arch}")) if host.arch)],
      [_("Operating System"), (link_to(host.os.to_label, hosts_path(:search => "os_description = #{host.os.description}")) if host.os)],
      [_("Host group"), (link_to(host.hostgroup, hosts_path(:search => %Q{hostgroup_title = "#{host.hostgroup}"})) if host.hostgroup)],
    ]
    fields += [[_("Location"), (link_to(host.location.title, hosts_path(:search => "location = #{host.location}")) if host.location)]] if SETTINGS[:locations_enabled]
    fields += [[_("Organization"), (link_to(host.organization.title, hosts_path(:search => "organization = #{host.organization}")) if host.organization)]] if SETTINGS[:organizations_enabled]
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

  def host_title_actions(host)
    title_actions(
        button_group(
            link_to_if_authorized(_("Edit"), hash_for_edit_host_path(:id => host).merge(:auth_object => host),
                                    :title    => _("Edit your host")),
            if host.build
              link_to_if_authorized(_("Cancel build"), hash_for_cancelBuild_host_path(:id => host).merge(:auth_object => host, :permission => 'build_hosts'),
                                    :disabled => host.can_be_built?,
                                    :title    => _("Cancel build request for this host"))
            else
              link_to_if_authorized(_("Build"), hash_for_setBuild_host_path(:id => host).merge(:auth_object => host, :permission => 'build_hosts'),
                                    :disabled => !host.can_be_built?,
                                    :title    => _("Enable rebuild on next host boot"),
                                    :confirm  => _("Rebuild %s on next reboot?\nThis would also delete all of its current facts and reports") % host)
            end
        ),
        if host.compute_resource_id || host.bmc_available?
          button_group(
              link_to(_("Loading power state ..."), '#', :disabled => true, :id => :loading_power_state)
          )
        end,
        button_group(
          if host.try(:puppet_proxy)
            link_to_if_authorized(_("Run puppet"), hash_for_puppetrun_host_path(:id => host).merge(:auth_object => host, :permission => 'puppetrun_hosts'),
                                  :disabled => !Setting[:puppetrun],
                                  :title    => _("Trigger a puppetrun on a node; requires that puppet run is enabled"))
          end
        ),
        button_group(
            link_to_if_authorized(_("Delete"), hash_for_host_path(:id => host).merge(:auth_object => host, :permission => 'destroy_hosts'),
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

  def has_dhcp_lease_errors? errors
    errors.include?(:dhcp_lease_error)
  end

  def args_for_compute_resource_partial(host)
    args = {}
    args[:arch] = host.try(:architecture_id) || (params[:host] && params[:host][:architecture_id])
    args[:os] = host.try(:operatingsystem_id) || (params[:host] && params[:host][:operatingsystem_id])
    args[:selected_cluster] = vm_attrs['cluster'] if defined?(vm_attrs)
    args
  end

  def show_appropriate_host_buttons(host)
    [ link_to_if_authorized(_("Audits"), hash_for_host_audits_path(:host_id => @host), :title => _("Host audit entries") , :class => 'btn btn-default'),
      (link_to_if_authorized(_("Facts"), hash_for_host_facts_path(:host_id => host), :title => _("Browse host facts") , :class => 'btn btn-default') if host.fact_values.any?),
      (link_to_if_authorized(_("Reports"), hash_for_host_reports_path(:host_id => host), :title => _("Browse host reports") , :class => 'btn btn-default') if host.reports.any?),
      (link_to(_("YAML"), externalNodes_host_path(:name => host), :title => _("Puppet external nodes YAML dump") , :class => 'btn btn-default') if SmartProxy.with_features("Puppet").any?)
    ].compact
  end

  def allocation_text_f f
    active = 'Size'
    active = 'None' if f.object.allocation.to_i == 0
    active = 'Full' if f.object.allocation == f.object.capacity
    text_f f, :allocation, :class => "input-mini", :label => _("Allocation (GB)"),
    :readonly => (active == 'Size') ? false : true,
    :help_inline => (content_tag(:span, :class => 'btn-group', :'data-toggle' => 'buttons-radio') do
      [N_('None'), N_('Size'), N_('Full')].collect do |label|
        content_tag :button, _(label), :type => 'button', :href => '#',
          :name => 'allocation_radio_btn',
          :class => (label == active) ? 'btn btn-default active' : 'btn btn-default',
          :onclick => "allocation_switcher(this, '#{label}');"
      end.join(' ').html_safe
    end)
  end

# helper method to provide data attribute if subnets has ipam enabled / disabled
  def subnets_ipam_data
    data = {}
    domain_subnets.each do |subnet|
      data[subnet.id] = { :ipam => subnet.ipam? }
    end
    data
  end

  def remove_interface_link(f)
    remove_child_link('x', f, {:rel => 'twipsy',
                               :'data-title' => _('remove network interface'),
                               :'data-placement' => 'left',
                               :class => 'fr label label-danger'})
  end

  def link_status(f)
    return '' if f.object.new_record?
    '(' + (f.object.link ? _('Up') : _('Down')) + ')'
  end
end
