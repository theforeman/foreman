module PuppetRelatedHelper
  UI.register_host_description do
    multiple_actions_provider :puppet_actions
    overview_fields_provider :puppet_host_overview_fields
    overview_buttons_provider :puppet_host_overview_buttons
  end

  def host_puppet_environment_field(form, select_options = {}, html_options = {})
    select_options = {
      :include_blank => true,
      :disable_button => _(HostsAndHostgroupsHelper::INHERIT_TEXT),
      :disable_button_enabled => inherited_by_default?(:environment_id, @host),
      :user_set => user_set?(:environment_id)}.deep_merge(select_options)

    html_options = {
      :data => {
        :url => hostgroup_or_environment_selected_hosts_path,
        :host => {
          :id => @host.id,
        },
      }}.deep_merge(html_options)

    puppet_environment_field(
      form,
      accessible_resource(@host, :environment),
      select_options,
      html_options)
  end

  def hostgroup_puppet_environment_field(form, select_options = {}, html_options = {})
    select_options = {
      :include_blank => blank_or_inherit_f(form, :environment),
    }.deep_merge(select_options)

    html_options = {
      :data => {
        :url => environment_selected_hostgroups_path,
      }}.deep_merge(html_options)

    puppet_environment_field(
      form,
      accessible_resource(@hostgroup, :environment),
      select_options,
      html_options)
  end

  def puppet_environment_field(form, environments_choice, select_options = {}, html_options = {})
    html_options = {
      :onchange => "update_puppetclasses(this)",
      :help_inline => :indicator}.deep_merge(html_options)

    select_f(
      form,
      :environment_id,
      environments_choice,
      :id,
      :to_label,
      select_options,
      html_options)
  end

  def interesting_puppetclasses(obj)
    classes = obj.all_puppetclasses
    classes_ids = classes.reorder(nil).pluck("puppetclasses.id")
    class_vars = PuppetclassLookupKey.reorder(nil).joins(:environment_classes).where(:environment_classes => { :puppetclass_id => classes_ids }).distinct.pluck("environment_classes.puppetclass_id")

    classes.where(:id => class_vars)
  end

  def puppet_actions
    actions = []
    if authorized_for(:controller => :hosts, :action => :edit)
      actions << { :action => [_('Change Puppet Master'), select_multiple_puppet_proxy_hosts_path], :priority => 1050 } if SmartProxy.unscoped.authorized.with_features("Puppet").exists?
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

  def puppet_host_overview_buttons(host)
    buttons = []
    buttons << { :button => link_to(_("YAML"), externalNodes_host_path(:name => host), :title => _("Puppet external nodes YAML dump"), :class => 'btn btn-default'), :priority => 400 } if SmartProxy.with_features("Puppet").any?
    buttons
  end
end
