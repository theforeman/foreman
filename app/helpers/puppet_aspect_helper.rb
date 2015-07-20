module PuppetAspectHelper
  def host_title_buttons(host)
    base = super || []
    base << button_group(link_to_if_authorized(_("Run puppet"), hash_for_puppetrun_host_path(:id => host).merge(:auth_object => host, :permission => 'puppetrun_hosts'),
                              :disabled => !Setting[:puppetrun],
                              :title    => _("Trigger a puppetrun on a node; requires that puppet run is enabled"))
                             ) if host.puppet_aspect.try(:puppet_proxy)
    base
  end

  def overview_fields(host)
    base = super
    base << [_("Puppet Environment"), (link_to(host.puppet_aspect.environment, hosts_path(:search => "environment = #{host.puppet_aspect.environment}")) if host.puppet_aspect and host.puppet_aspect.environment)]
    base
  end

  def host_additional_tabs(host)
    base = super || []

    if SmartProxy.with_features("Puppet").count > 0
      base << [content_tag(:li,
                 link_to(_('Puppet Classes'), "#puppet_klasses", :data => { :toggle => 'tab'} )
                 ),
               render('puppet_aspects/puppetclasses_tab')]
    end
    base
  end
end
