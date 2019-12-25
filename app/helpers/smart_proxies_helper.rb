module SmartProxiesHelper
  TABBED_FEATURES = ["Puppet", "Puppet CA", "Logs"]

  def proxy_actions(proxy, authorizer)
    actions = []
    actions << display_link_if_authorized(_("Edit"), hash_for_edit_smart_proxy_path(:id => proxy))
    actions << display_delete_if_authorized(hash_for_smart_proxy_path(:id => proxy).merge(:auth_object => proxy, :authorizer => authorizer),
      :data => {:confirm => _("Delete %s?") % proxy.name}, :class => 'delete')
    actions << feature_actions(proxy, authorizer)
    actions
  end

  def feature_actions(proxy, authorizer)
    actions = []

    actions << display_link_if_authorized(_("Refresh"), hash_for_refresh_smart_proxy_path(:id => proxy).
                                                                 merge(:auth_object => proxy, :permission => 'edit_smart_proxies', :authorizer => authorizer), :method => :put)

    if proxy.has_feature?('Puppet CA')
      actions << display_link_if_authorized(_("Certificates"), hash_for_smart_proxy_path(:id => proxy).
                                                               merge(:auth_object => proxy, :permission => 'view_smart_proxies_puppetca', :authorizer => authorizer, :anchor => 'certificates'))

      actions << display_link_if_authorized(_("Autosign"), hash_for_smart_proxy_path(:id => proxy).
                                                           merge(:auth_object => proxy, :permission => 'view_smart_proxies_autosign', :authorizer => authorizer, :anchor => 'autosign'))
    end

    if SETTINGS[:unattended] && proxy.has_feature?('DHCP')
      actions << display_link_if_authorized(_("Import IPv4 subnets"), hash_for_import_subnets_path(:smart_proxy_id => proxy))
    end

    if proxy.has_feature?('Logs')
      actions << link_to_function_if_authorized(_('Expire logs'), "expireLogs(this, (new Date).getTime() / 1000);",
        hash_for_expire_logs_smart_proxy_path(:id => proxy), {
          :data => {
            :url => expire_logs_smart_proxy_path(:id => proxy),
            :"url-errors" => errors_card_smart_proxy_path(:id => proxy),
            :"url-modules" => modules_card_smart_proxy_path(:id => proxy),
          },
        })
    end

    actions << render_pagelets_for(:smart_proxy_title_actions, :subject => proxy)

    actions
  end

  def smart_proxy_title_actions(proxy, authorizer)
    title_actions(
      select_action_button(_("Actions"), {}, feature_actions(proxy, authorizer)),
      button_group(
        display_link_if_authorized(_("Edit"), hash_for_edit_smart_proxy_path(:id => proxy), :class => 'btn btn-default')
      ),
      button_group(
        display_delete_if_authorized(hash_for_smart_proxy_path(:id => proxy).merge(:auth_object => proxy, :authorizer => authorizer),
          :data => {:confirm => _("Delete %s?") % proxy.name}, :class => 'btn btn-default')
      )
    )
  end

  def refresh_proxy_button(proxy, authorizer)
    display_link_if_authorized('Refresh features', hash_for_refresh_smart_proxy_path(:id => proxy).
                                                     merge(:auth_object => proxy, :permission => 'edit_smart_proxies', :authorizer => authorizer), :method => :put, :class => 'btn btn-default')
  end

  def services_tab_features(proxy)
    proxy.features.where('features.name NOT IN (?)', TABBED_FEATURES).distinct.pluck("name").sort
  end

  def tabbed_features(proxy)
    proxy.features.where('features.name IN (?)', TABBED_FEATURES).distinct.pluck("name").sort
  end

  def show_feature_version(feature)
    render :partial => 'smart_proxies/plugins/plugin_version', :locals => { :feature => feature }
  end

  def logs_color_map
    {
      'DEBUG' => 'success',
      'INFO' => 'info',
      'WARN' => 'warning',
      'ERROR' => 'danger',
      'FATAL' => 'danger',
    }
  end

  def logs_filter_tag
    select_tag "Filter", options_for_select(
      [[_('All'), '']] +
      [[_('ERROR or FATAL'), 'ERROR|FATAL']] +
      [[_('WARNING'), 'WARN']] +
      [[_('INFO or DEBUG'), 'INFO|DEBUG']]), :class => "datatable-filter", :id => "logs-filter"
  end
end
