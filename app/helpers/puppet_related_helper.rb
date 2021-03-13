module PuppetRelatedHelper
  UI.register_host_description do
    multiple_actions_provider :puppet_actions
  end

  def puppet_actions
    actions = []
    if authorized_for(:controller => :hosts, :action => :edit)
      actions << { :action => [_('Change Puppet CA'), select_multiple_puppet_ca_proxy_hosts_path], :priority => 1051 } if SmartProxy.unscoped.authorized.with_features("Puppet CA").exists?
    end
    actions
  end
end
