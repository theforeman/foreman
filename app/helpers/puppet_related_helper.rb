module PuppetRelatedHelper
  UI.register_host_description do
    multiple_actions_provider :puppet_actions
    overview_fields_provider :puppet_host_overview_fields
  end

  def puppet_actions
    actions = []
    if authorized_for(:controller => :hosts, :action => :edit)
      actions << { :action => [_('Change Puppet CA'), select_multiple_puppet_ca_proxy_hosts_path], :priority => 1051 } if SmartProxy.unscoped.authorized.with_features("Puppet CA").exists?
    end
    actions
  end

  def puppet_host_overview_fields(host)
    fields = []
    if host.environment.present?
      fields << {
        :field => [
          _("Puppet Environment"),
          link_to(host.environment, hosts_path(:search => "environment = #{host.environment}")),
        ],
        :priority => 650,
      }
    end
    fields
  end
end
