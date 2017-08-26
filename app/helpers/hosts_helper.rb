module HostsHelper
  include OperatingsystemsHelper
  include HostsAndHostgroupsHelper
  include ComputeResourcesVmsHelper
  include HostsNicHelper
  include BmcHelper

  def provider_partial_exist?(compute_resource, partial)
    return false unless compute_resource

    compute_resource_name = compute_resource.provider.downcase
    ActionController::Base.view_paths.any? do |path|
      File.exist?(File.join(path, 'compute_resources_vms', 'form', compute_resource_name, "_#{partial}.html.erb"))
    end
  end

  def provider_partial(compute_resource, partial)
    return nil unless compute_resource

    compute_resource_name = compute_resource.provider.downcase
    "compute_resources_vms/form/#{compute_resource_name}/#{partial}"
  end

  def provision_method_partial_exist?(provision_method, partial)
    return false unless provision_method

    ActionController::Base.view_paths.any? do |path|
      File.exist?(File.join(path, 'hosts', 'provision_method', provision_method, "_#{partial}.html.erb"))
    end
  end

  def provision_method_partial(provision_method, partial)
    return nil unless provision_method

    "hosts/provision_method/#{provision_method}/#{partial}"
  end

  def compute_specific_js(compute_resource, js_name)
    javascript_include_tag("compute_resources/#{compute_resource.provider.downcase}/#{js_name}.js")
  end

  def value_hash_cache(host)
    @value_hash_cache ||= {}
    @value_hash_cache[host.id] ||= begin
      info = HostInfoProviders::PuppetInfo.new(host)
      info.inherited_puppetclass_parameters.
        merge(info.inherited_smart_variables)
    end
  end

  def host_taxonomy_select(f, taxonomy)
    taxonomy_id = "#{taxonomy.to_s.downcase}_id"
    selected_taxonomy = @host.new_record? ? taxonomy.current.try(:id) : @host.send(taxonomy_id)
    select_opts = { :include_blank => !@host.managed? || @host.send(taxonomy_id).nil?,
                    :selected => selected_taxonomy }
    html_opts = { :disabled => !@host.new_record?,
                  :onchange => "#{taxonomy.to_s.downcase}_changed(this);",
                  :label => _(taxonomy.to_s),
                  :'data-host-id' => @host.id,
                  :'data-url' => process_taxonomy_hosts_path,
                  :help_inline => :indicator,
                  :required => true }

    select_f f, taxonomy_id.to_sym, taxonomy.send("my_#{taxonomy.to_s.downcase.pluralize}"), :id, :to_label,
            select_opts, html_opts
  end

  def new_host_title
    t = _("Create Host")
    title(t, (t + ' <span id="hostFQDN"></span>').html_safe)
  end

  def flags_for_nic(nic)
    flags = ""
    flags += "<i class=\"nic-flag glyphicon glyphicon glyphicon-tag\" title=\"#{_('Primary')}\"></i>" if nic.primary?
    flags += "<i class=\"nic-flag glyphicon glyphicon glyphicon-hdd\" title=\"#{_('Provisioning')}\"></i>" if nic.provision?
    flags.html_safe
  end

  def last_report_column(record)
    time = record.last_report? ? _("%s ago") % time_ago_in_words(record.last_report): ""
    link_to_if_authorized(time,
                          hash_for_host_config_report_path(:host_id => record.to_param, :id => "last"),
                          last_report_tooltip(record))
  end

  def last_report_tooltip(record)
    opts = { :rel => "twipsy" }
    if @last_report_ids[record.id]
      opts["data-original-title"] = _("View last report details")
    else
      opts.merge!(:disabled => true, :class => "disabled", :onclick => 'return false')
      opts["data-original-title"] = _("Report Already Deleted") unless record.last_report.nil?
    end
    opts
  end

  # method that reformat the hostname column by adding the status icons
  def name_column(host)
    style = host_global_status_icon_class_for_host(host)
    tooltip = host.host_statuses.select(&:relevant?).sort_by(&:type).map { |status| "#{_(status.name)}: #{_(status.to_label)}" }.join(', ')

    content = content_tag(:span, "", {:rel => "twipsy", :class => style, :"data-original-title" => tooltip})
    content += link_to("  #{host}", host_path(host))
    content
  end

  def host_global_status_icon_class_for_host(host)
    options = {}
    options[:last_reports] = @last_reports unless @last_reports.nil?
    host_global_status_icon_class(host.build_global_status(options).status)
  end

  def host_global_status_icon_class(status)
    icon_class = case status
                 when HostStatus::Global::OK
                   'pficon-ok'
                 when HostStatus::Global::WARN
                   'pficon-info'
                 when HostStatus::Global::ERROR
                   'pficon-error-circle-o'
                 else
                   'pficon-help'
                 end

    "host-status #{icon_class} #{host_global_status_class(status)}"
  end

  def host_global_status_class(status)
    case status
      when HostStatus::Global::OK
        'status-ok'
      when HostStatus::Global::WARN
        'status-warn'
      when HostStatus::Global::ERROR
        'status-error'
      else
        'status-question'
    end
  end

  def days_ago(time)
    ((Time.zone.now - time) / 1.day).ceil.to_i
  end

  def searching?
    params[:search].empty?
  end

  def multiple_actions
    actions = []
    if authorized_for(:controller => :hosts, :action => :edit)
      actions.concat [
        [_('Change Group'), select_multiple_hostgroup_hosts_path],
        [_('Change Environment'), select_multiple_environment_hosts_path],
        [_('Edit Parameters'), multiple_parameters_hosts_path],
        [_('Disable Notifications'), multiple_disable_hosts_path],
        [_('Enable Notifications'), multiple_enable_hosts_path],
        [_('Disassociate Hosts'), multiple_disassociate_hosts_path],
        [_('Rebuild Config'), rebuild_config_hosts_path]
      ]
      actions.insert(1, [_('Build Hosts'), multiple_build_hosts_path]) if SETTINGS[:unattended]
      actions <<  [_('Assign Organization'), select_multiple_organization_hosts_path] if SETTINGS[:organizations_enabled]
      actions <<  [_('Assign Location'), select_multiple_location_hosts_path] if SETTINGS[:locations_enabled]
      actions <<  [_('Change Owner'), select_multiple_owner_hosts_path] if SETTINGS[:login]
      actions <<  [_('Change Puppet Master'), select_multiple_puppet_proxy_hosts_path] if SmartProxy.unscoped.authorized.with_features("Puppet").exists?
      actions <<  [_('Change Puppet CA'), select_multiple_puppet_ca_proxy_hosts_path] if SmartProxy.unscoped.authorized.with_features("Puppet CA").exists?
    end
    actions <<  [_('Run Puppet'), multiple_puppetrun_hosts_path] if Setting[:puppetrun] && authorized_for(:controller => :hosts, :action => :puppetrun)
    actions <<  [_('Change Power State'), select_multiple_power_state_hosts_path] if authorized_for(:controller => :hosts, :action => :power)
    actions << [_('Delete Hosts'), multiple_destroy_hosts_path] if authorized_for(:controller => :hosts, :action => :destroy)
    actions
  end

  def multiple_actions_select
    select_action_button(_("Select Action"), {:id => 'submit_multiple'},
      multiple_actions.map do |action|
        # If the action array has 3 entries, the third one is whether to use a modal dialog or not
        modal = action.size == 3 ? action[3] : true
        if modal
          link_to_function(action[0], "build_modal(this, '#{action[1]}')", :'data-dialog-title' => _("%s - The following hosts are about to be changed") % action[0])
        else
          link_to_function(action[0], "build_redirect('#{action[1]}')")
        end
      end.flatten
    )
  end

  def date(ts = nil)
    return _("%s ago") % (time_ago_in_words ts) if ts
    _("N/A")
  end

  def template_path(opts = {})
    if (t = @host.provisioning_template(opts))
      link_to t, edit_provisioning_template_path(t)
    else
      _("N/A")
    end
  end

  def selected?(host)
    return false if host.nil? || !host.is_a?(Host::Base) || session[:selected].nil?
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
    return if @host.reports.empty?
    number_of_days = days_ago(@host.reports.order(:reported_at).first.reported_at)
    width = [number_of_days.to_s.size + 2, 4].max

    form_tag @host, :id => 'days_filter', :method => :get, :class => "form form-inline" do
      content_tag(:span, (_("Found %{count} reports from the last %{days} days") %
        { :days  => select(nil, 'range', 1..number_of_days,
                    {:selected => @range}, {:style=>"float:none; width: #{width}em;", :onchange =>"$('#days_filter').submit();$(this).disabled();"}),
          :count => @host.reports.recent(@range.days.ago).count }).html_safe)
    end
  end

  def name_field(host)
    return if host.name.blank?
    (SETTINGS[:unattended] && host.managed?) ? host.shortname : host.name
  end

  def overview_fields(host)
    global_status = host.build_global_status
    fields = [
      [_("Status"), content_tag(:span, ''.html_safe, :class => host_global_status_icon_class(global_status.status)) +
                    content_tag(:span, _(global_status.to_label), :class => host_global_status_class(global_status.status))
      ]
    ]
    fields += host_detailed_status_list(host)
    fields += [[_("Domain"), (link_to(host.domain, hosts_path(:search => %{domain = "#{host.domain}"})))]] if host.domain.present?
    fields += [[_("Realm"), (link_to(host.realm, hosts_path(:search => %{realm = "#{host.realm}"})))]] if host.realm.present?
    fields += [[_("IP Address"), host.ip]] if host.ip.present?
    fields += [[_("IPv6 Address"), host.ip6]] if host.ip6.present?
    fields += [[_("Comment"), host.comment]] if host.comment.present?
    fields += [[_("MAC Address"), host.mac]] if host.mac.present?
    fields += [[_("Puppet Environment"), (link_to(host.environment, hosts_path(:search => %{environment = "#{host.environment}"})))]] if host.environment.present?
    fields += [[_("Architecture"), (link_to(host.arch, hosts_path(:search => %{architecture = "#{host.arch}"})))]] if host.arch.present?
    fields += [[_("Operating System"), (link_to(host.operatingsystem.to_label, hosts_path(:search => %{os_title = "#{host.operatingsystem.title}"})))]] if host.operatingsystem.present?
    fields += [[_("PXE Loader"), host.pxe_loader]] if host.operatingsystem.present? && host.pxe_build?
    fields += [[_("Host group"), (link_to(host.hostgroup, hosts_path(:search => %{hostgroup_title = "#{host.hostgroup}"})))]] if host.hostgroup.present?
    fields += [[_("Location"), (link_to(host.location.title, hosts_path(:search => %{location = "#{host.location}"})) if host.location)]] if SETTINGS[:locations_enabled]
    fields += [[_("Organization"), (link_to(host.organization.title, hosts_path(:search => %{organization = "#{host.organization}"})) if host.organization)]] if SETTINGS[:organizations_enabled]
    if SETTINGS[:login]
      if host.owner_type == _("User")
        fields += [[_("Owner"), (link_to(host.owner, hosts_path(:search => %{user.login = "#{host.owner.login}"})) if host.owner)]]
      else
        fields += [[_("Owner"), host.owner]]
      end
    end
    fields += [[_("Certificate Name"), host.certname]] if Setting[:use_uuid_for_certificates]
    fields
  end

  def host_detailed_status_list(host)
    host.host_statuses.sort_by(&:type).map do |status|
      next unless status.relevant?
      [
        _(status.name),
        content_tag(:span, ' '.html_safe, :class => host_global_status_icon_class(status.to_global)) +
          content_tag(:span, _(status.to_label), :class => host_global_status_class(status.to_global))
      ]
    end.compact
  end

  def possible_images(cr, arch = nil, os = nil)
    return cr.images.order(:name) unless controller_name == "hosts"
    return [] unless arch && os
    cr.images.where(:architecture_id => arch, :operatingsystem_id => os).order(:name)
  end

  def state(s)
    s ? ' ' + _("Off") : ' ' + _("On")
  end

  def host_title_actions(host)
    title_actions(
      button_group(
        link_to(_("Back"), hosts_path, :class => 'btn btn-default')
      ),
      button_group(
        link_to_if_authorized(_("Edit"), hash_for_edit_host_path(:id => host).merge(:auth_object => host),
                                :title    => _("Edit this host"), :id => "edit-button", :class => 'btn btn-default'),
        display_link_if_authorized(_("Clone"), hash_for_clone_host_path(:id => host).merge(:auth_object => host),
                                :title    => _("Clone this host"), :id => "clone-button", :class => 'btn btn-default'),
        if host.build
          link_to_if_authorized(_("Cancel build"), hash_for_cancelBuild_host_path(:id => host).merge(:auth_object => host, :permission => 'build_hosts'),
                                :disabled => host.can_be_built?,
                                :title    => _("Cancel build request for this host"), :id => "cancel-build-button", :class => 'btn btn-default')
        else
          link_to_if_authorized(_("Build"), hash_for_host_path(:id => host).merge(:auth_object => host, :permission => 'build_hosts', :anchor => "review_before_build"),
                                :disabled => !host.can_be_built?,
                                :title    => _("Enable rebuild on next host boot"),
                                :class    => "btn btn-default",
                                :id       => "build-review",
                                :data     => { :toggle => 'modal',
                                               :target => '#review_before_build',
                                               :url    => review_before_build_host_path(:id => host)
                                }
          )
        end
      ),
      if host.supports_power?
        button_group(
            link_to(_("Loading power state ..."), '#', :disabled => true, :class => 'btn btn-default', :id => :loading_power_state)
        )
      end,
      button_group(
        if host.try(:puppet_proxy)
          link_to_if_authorized(_("Run puppet"), hash_for_puppetrun_host_path(:id => host).merge(:auth_object => host, :permission => 'puppetrun_hosts'),
                                :disabled => !Setting[:puppetrun],
                                :class => 'btn btn-default',
                                :title    => _("Trigger a puppetrun on a node; requires that puppet run is enabled"))
        end
      ),
      button_group(
        link_to_if_authorized(_("Delete"), hash_for_host_path(:id => host).merge(:auth_object => host, :permission => 'destroy_hosts'),
                              :class => "btn btn-danger",
                              :id => "delete-button",
                              :data => { :message => delete_host_dialog(host) },
                              :method => :delete)
      )
    )
  end

  def delete_host_dialog(host)
    if host.compute?
      _("Are you sure you want to delete host %s? This will delete the virtual machine and its disks, and is irreversible.") % host.name
    else
      _("Are you sure you want to delete host %s? This action is irreversible.") % host.name
    end
  end

  # we ignore interfaces.conflict because they are always registered in host errors as well
  def conflict_objects(errors)
    errors.keys.map(&:to_s).select { |key| key =~ /conflict$/ && key != 'interfaces.conflict' }.map(&:to_sym)
  end

  def has_conflicts?(errors)
    conflict_objects(errors).each do |c|
      return true if errors[c.to_sym].any?
    end
    false
  end

  def has_dhcp_lease_errors?(errors)
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
    [ link_to_if_authorized(_("Audits"), hash_for_host_audits_path(:host_id => @host), :title => _("Host audit entries"), :class => 'btn btn-default'),
      (link_to_if_authorized(_("Facts"), hash_for_host_facts_path(:host_id => host), :title => _("Browse host facts"), :class => 'btn btn-default') if host.fact_values.any?),
      (link_to_if_authorized(_("Reports"), hash_for_host_config_reports_path(:host_id => host), :title => _("Browse host config management reports"), :class => 'btn btn-default') if host.reports.any?),
      (link_to(_("YAML"), externalNodes_host_path(:name => host), :title => _("Puppet external nodes YAML dump"), :class => 'btn btn-default') if SmartProxy.with_features("Puppet").any?)
    ].compact
  end

  def allocation_text_f(f)
    active = 'Size'
    active = 'None' if f.object.allocation.to_i == 0
    active = 'Full' if f.object.allocation == f.object.capacity
    text_f f, :allocation, :class => "input-mini", :label => _("Allocation (GB)"), :label_size => "col-md-2",
    :readonly => (active == 'Size') ? false : true,
    :help_inline => (content_tag(:span, :class => 'btn-group', :'data-toggle' => 'buttons-radio') do
      [N_('None'), N_('Size'), N_('Full')].collect do |label|
        content_tag :button, _(label), :type => 'button', :href => '#',
          :name => 'allocation_radio_btn',
          :class => (label == active) ? 'btn btn-default active' : 'btn btn-default',
          :onclick => "allocation_switcher(this, '#{label}');",
          :data => { :toggle => 'button' }
      end.join(' ').html_safe
    end)
  end

# helper method to provide data attribute if subnets has ipam enabled / disabled
  def subnets_ipam_data(field)
    data = {}
    domain_subnets(field).each do |subnet|
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

  def link_status(nic)
    return '' if nic.new_record?

    if nic.link
      status = '<i class="glyphicon glyphicon glyphicon-arrow-up interface-up" title="'+ _('Interface is up') +'"></i>'
    else
      status = '<i class="glyphicon glyphicon glyphicon-arrow-down interface-down" title="'+ _('Interface is down') +'"></i>'
    end
    status.html_safe
  end

  def interface_flags(nic)
    primary_class = nic.primary? ? "active" : ""
    provision_class = nic.provision? ? "active" : ""

    status = "<i class=\"glyphicon glyphicon glyphicon-tag primary-flag #{primary_class}\" title=\"#{_('Primary')}\"></i>"
    status += "<i class=\"glyphicon glyphicon glyphicon-hdd provision-flag #{provision_class}\" title=\"#{_('Provisioning')}\"></i>"
    status.html_safe
  end

  def build_state(build)
    build.state ? 'warning' : 'danger'
  end

  def review_build_button(form, status)
    form.submit(_("Build"),
                :class => "btn btn-#{status} submit",
                :title => (status == 'warning') ? _('Build') : _('Errors occurred, build may fail')
    )
  end

  def build_error_link(type, id)
    case type
      when :templates
        link_to_if_authorized(_("Edit"), hash_for_edit_provisioning_template_path(:id => id).merge(:auth_object => id),
                              :class => "btn btn-default btn-xs pull-right", :title => _("Edit %s" % type))
    end
  end

  def inherited_by_default?(field, host)
    return false unless host.hostgroup && host.hostgroup_id_was.nil?
    return false if params[:action] == 'clone'
    return true unless params[:host]
    !params[:host][field]
  end

  def multiple_proxy_select(form, proxy_feature)
    selectable_f form,
      :proxy_id,
      [[_("Select desired %s proxy") % _(proxy_feature), "disabled"]] +
      [[_("*Clear %s proxy*") % _(proxy_feature), "" ]] +
      SmartProxy.with_features(proxy_feature).map {|p| [p.name, p.id]},
      {},
      {:label => _(proxy_feature), :onchange => "toggle_multiple_ok_button(this)" }
  end

  def randomize_mac_link
    link_to_function(icon_text('random'), 'randomizeName()', :class => 'btn btn-default',
      :title => _('Generate new random name. Visit Settings to disable this feature.')) if NameGenerator.random_based?
  end

  def power_status_visible?
    SETTINGS[:unattended] && Setting[:host_power_status]
  end
end
