module SmartProxiesHelper
  def proxy_actions(proxy, authorizer)
    [if proxy.has_feature?('Puppet CA')
       [display_link_if_authorized(_("Certificates"), hash_for_smart_proxy_puppetca_index_path(:smart_proxy_id => proxy).
                                merge(:auth_object => proxy, :permission => 'view_smart_proxies_puppetca', :authorizer => authorizer)),
        display_link_if_authorized(_("Autosign"), hash_for_smart_proxy_autosign_index_path(:smart_proxy_id => proxy).
                                merge(:auth_object => proxy, :permission => 'view_smart_proxies_autosign', :authorizer => authorizer))]
     end,

     if SETTINGS[:unattended] and proxy.has_feature?('DHCP')
       display_link_if_authorized(_("Import subnets"), hash_for_import_subnets_path(:smart_proxy_id => proxy))
     end,

     display_link_if_authorized(_("Refresh features"), hash_for_refresh_smart_proxy_path(:id => proxy).
                               merge(:auth_object => proxy, :permission => 'edit_smart_proxies', :authorizer => authorizer), :method => :put),

     display_delete_if_authorized(hash_for_smart_proxy_path(:id => proxy).merge(:auth_object => proxy, :authorizer => authorizer), :data => { :confirm => _("Delete %s?") % proxy.name })]
  end
end
