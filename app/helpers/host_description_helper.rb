module HostDescriptionHelper
  UI.register_host_description do
    multiple_actions_provider :base_multiple_actions
    overview_fields_provider :base_status_overview_fields
    overview_fields_provider :base_host_overview_fields
    overview_buttons_provider :base_host_overview_buttons
    title_actions_provider :base_host_title_actions
  end

  def base_multiple_actions
    actions = []
    if authorized_for(:controller => :hosts, :action => :edit)
      actions.concat [
        { :action => [_('Change Group'), select_multiple_hostgroup_hosts_path], :priority => 100 },
        { :action => [_('Edit Parameters'), multiple_parameters_hosts_path], :priority => 300 },
        { :action => [_('Disable Notifications'), multiple_disable_hosts_path], :priority => 400 },
        { :action => [_('Enable Notifications'), multiple_enable_hosts_path], :priority => 500 },
        { :action => [_('Disassociate Hosts'), multiple_disassociate_hosts_path], :priority => 600 },
        { :action => [_('Rebuild Config'), rebuild_config_hosts_path], :priority => 700 },
      ]
      actions << { :action => [_('Build Hosts'), multiple_build_hosts_path], :priority => 110 } if SETTINGS[:unattended]
      actions <<  { :action => [_('Assign Organization'), select_multiple_organization_hosts_path], :priority => 800 }
      actions <<  { :action => [_('Assign Location'), select_multiple_location_hosts_path], :priority => 900 }
      actions <<  { :action => [_('Change Owner'), select_multiple_owner_hosts_path], :priority => 1000 }
    end
    actions << { :action => [_('Change Power State'), select_multiple_power_state_hosts_path], :priority => 1100 } if authorized_for(:controller => :hosts, :action => :power)
    actions << { :action => [_('Delete Hosts'), multiple_destroy_hosts_path], :priority => 1200 } if authorized_for(:controller => :hosts, :action => :destroy)
    actions
  end

  def base_status_overview_fields(host)
    global_status = host.build_global_status
    fields = [
      {
        :field => [
          _("Status"),
          content_tag(:span, ''.html_safe, :class => host_global_status_icon_class(global_status.status)) +
            content_tag(:span, _(global_status.to_label), :class => host_global_status_class(global_status.status)),
        ],
        :priority => 10,
      },
    ]
    fields += host_detailed_status_list(host)

    fields
  end

  def host_detailed_status_list(host)
    priority = 10
    host.host_statuses.sort_by(&:type).map do |status|
      next unless status.relevant? && !status.substatus?
      { :field => [
        _(status.name),
        content_tag(:span, ' '.html_safe, :class => host_global_status_icon_class(status.to_global)) +
            link_to_if(status.status_link, content_tag(:span, _(status.to_label), :class => host_global_status_link_class(status)), status.status_link) +
            content_tag(:span, link_to(_('clear'), forget_status_host_path(host, status: status), :class => 'pull-right', :method => 'post')),
      ], :priority => priority += 1 }
    end.compact
  end

  def base_host_overview_fields(host)
    fields = []
    fields << { :field => [_("Build duration"), build_duration(host)], :priority => 90 }
    fields << { :field => [_("Build errors"), link_to("Logs from OS installer", build_errors_host_path(:id => host.id))], :priority => 91 } if host.build_errors.present?
    fields << { :field => [_("Token"), host.token || _("N/A")], :priority => 92 } if User.current.admin
    fields << { :field => [_("Domain"), link_to(host.domain, hosts_path(:search => "domain = #{host.domain}"))], :priority => 100 } if host.domain.present?
    fields << { :field => [_("Realm"), link_to(host.realm, hosts_path(:search => "realm = #{host.realm}"))], :priority => 200 } if host.realm.present?
    fields << { :field => [_("IP Address"), host.ip], :priority => 300 } if host.ip.present?
    fields << { :field => [_("IPv6 Address"), host.ip6], :priority => 400 } if host.ip6.present?
    fields << { :field => [_("Comment"), host.comment], :priority => 500 } if host.comment.present?
    fields << { :field => [_("MAC Address"), host.mac], :priority => 600 } if host.mac.present?
    fields << { :field => [_("Architecture"), link_to(host.arch, hosts_path(:search => "architecture = #{host.arch}"))], :priority => 700 } if host.arch.present?
    fields << { :field => [_("Operating System"), link_to(host.operatingsystem.to_label, hosts_path(:search => %{os_title = "#{host.operatingsystem.title}"}))], :priority => 800 } if host.operatingsystem.present?
    fields << { :field => [_("PXE Loader"), host.pxe_loader], :priority => 900 } if host.operatingsystem.present? && !host.image_build?
    fields << { :field => [_("Host group"), link_to(host.hostgroup, hosts_path(:search => %{hostgroup_title = "#{host.hostgroup}"}))], :priority => 1000 } if host.hostgroup.present?
    fields << { :field => [_("Boot time"), (boot_time = host&.reported_data&.boot_time) ? date_time_relative(boot_time) : _('Not reported')], :priority => 1100 }
    fields << { :field => [_("Location"), link_to(host.location.title, hosts_path(:search => "location = \"#{host.location}\""))], :priority => 1200 } if host.location.present?
    fields << { :field => [_("Organization"), link_to(host.organization.title, hosts_path(:search => "organization = \"#{host.organization}\""))], :priority => 1300 } if host.organization.present?
    if host.owner_type == "User"
      fields << { :field => [_("Owner"), (link_to(host.owner, hosts_path(:search => %{user.login = "#{host.owner.login}"})) if host.owner)], :priority => 1400 }
    else
      fields << { :field => [_("Owner"), host.owner], :priority => 1400 }
    end
    fields << { :field => [_("Certificate Name"), host.certname], :priority => 1500 } if Setting[:use_uuid_for_certificates]
    fields
  end

  def base_host_title_actions(host)
    [
      {
        :action => button_group(
          link_to_if_authorized(_("Edit"), hash_for_edit_host_path(:id => host).merge(:auth_object => host),
            :title    => _("Edit this host"), :id => "edit-button", :class => 'btn btn-default'),
          display_link_if_authorized(_("Clone"), hash_for_clone_host_path(:id => host).merge(:auth_object => host, :permission => 'create_hosts'),
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
                             :url    => review_before_build_host_path(:id => host),
                           })
          end
        ),
        :priority => 100 },
      if host.supports_power?
        {
          :action => button_group(
            link_to(_("Loading power state ..."), '#', :disabled => true, :class => 'btn btn-default', :id => :loading_power_state)
          ),
          :priority => 200,
        }
      end,
      {
        :action => button_group(
          link_to_if_authorized(_("Delete"), hash_for_host_path(:id => host).merge(:auth_object => host, :permission => 'destroy_hosts'),
            :class => "btn btn-danger",
            :id => "delete-button",
            :data => { :message => delete_host_dialog(host) },
            :method => :delete)
        ),
        :priority => 300,
      },
    ].compact
  end

  def base_host_overview_buttons(host)
    [
      { :button => link_to_if_authorized(_("Audits"), { :controller => 'audits', :action => 'index', :search => "host = #{host.name}" }, :title => _("Host audit entries"), :class => 'btn btn-default'), :priority => 100 },
      ({ :button => link_to_if_authorized(_("Facts"), hash_for_host_facts_path(:host_id => host), :title => _("Browse host facts"), :class => 'btn btn-default'), :priority => 200 } if host.fact_values.any?),
      ({ :button => link_to_if_authorized(_("Reports"), hash_for_host_config_reports_path(:host_id => host), :title => _("Browse host config management reports"), :class => 'btn btn-default'), :priority => 300 } if host.reports.any?),
    ].compact
  end
end
