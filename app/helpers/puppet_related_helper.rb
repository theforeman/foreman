module PuppetRelatedHelper
  UI.register_host_description do
    multiple_actions_provider :puppet_actions
  end

  def puppet_actions
    return [] unless Foreman::Plugin.installed?('foreman_puppet')
    return [] unless authorized_for(:controller => :hosts, :action => :edit)
    return [] unless SmartProxy.unscoped.authorized.with_features("Puppet CA").exists?

    [{ :action => [_('Change Puppet CA'), select_multiple_puppet_ca_proxy_hosts_path], :priority => 1051 }]
  end
end
