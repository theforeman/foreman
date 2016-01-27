module SmartProxiesHelper
  TABBED_FEATURES = ["Puppet","Puppet CA", "DHCP"]

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

    if SETTINGS[:unattended] and proxy.has_feature?('DHCP')
      actions << display_link_if_authorized(_("Import subnets"), hash_for_import_subnets_path(:smart_proxy_id => proxy))
    end

    actions << render_pagelets_for(:smart_proxy_title_actions, :subject => proxy)

    actions
  end

  def smart_proxy_title_actions(proxy, authorizer)
    title_actions(
      button_group(
        link_to(_("Back"), smart_proxies_path)
      ),
      select_action_button(_("Select Action"), {}, feature_actions(proxy, authorizer)),
      button_group(
        display_link_if_authorized(_("Edit"), hash_for_edit_smart_proxy_path(:id => proxy))
      ),
      button_group(
        display_delete_if_authorized(hash_for_smart_proxy_path(:id => proxy).merge(:auth_object => proxy, :authorizer => authorizer),
                                     :data => {:confirm => _("Delete %s?") % proxy.name}, :class => 'btn-danger')
      )
    )
  end

  def refresh_proxy_icon(proxy, authorizer)
    display_link_if_authorized(icon_text("refresh"), hash_for_refresh_smart_proxy_path(:id => proxy).
                                                     merge(:auth_object => proxy, :permission => 'edit_smart_proxies', :authorizer => authorizer), :method => :put)
  end

  def services_tab_features(proxy)
    proxy.features.where('features.name NOT IN (?)', TABBED_FEATURES).uniq.pluck("name")
  end

  def tabbed_features(proxy)
    proxy.features.where('features.name IN (?)', TABBED_FEATURES).uniq.pluck("name")
  end

  def show_feature_version(feature)
    render :partial => 'smart_proxies/plugins/plugin_version', :locals => { :feature => feature }
  end

  def subnet_label(subnet)
    foreman_subnet = Subnet.subnet_for(subnet.network)
    if foreman_subnet
      foreman_subnet.to_label
    else
      subnet.network
    end
  end
end
