module HostsAndHostgroupsHelper
  include AncestryHelper

  def model_name(host)
    name = host.try(:model)
    name = host.compute_resource.name if host.compute_resource
    name
  end

  def parent_classes(obj)
    return obj.hostgroup.classes if obj.is_a?(Host::Base) && obj.hostgroup
    return obj.is_root? ? [] : obj.parent.classes if obj.is_a?(Hostgroup)
    []
  end

  def accessible_puppet_ca_proxies(obj)
    list = accessible_resource_records(:smart_proxy).with_features("Puppet CA").to_a
    current = obj.puppet_ca_proxy
    list |= [current] if current.present?
    list
  end

  def accessible_puppet_proxies(obj)
    list = accessible_resource_records(:smart_proxy).with_features("Puppet").to_a
    current = obj.puppet_proxy
    list |= [current] if current.present?
    list
  end

  def domain_subnets(type)
    accessible_related_resource(@domain, :subnets, :where => {:type => type})
  end

  def arch_oss
    accessible_related_resource(@architecture, :operatingsystems)
  end

  def os_media
    accessible_related_resource(@operatingsystem, :media)
  end

  def os_ptable
    accessible_related_resource(@operatingsystem, :ptables)
  end

  INHERIT_TEXT = N_("inherit")

  def realm_field(f, can_override = false, override = false)
    # Don't show this if we have no Realms, otherwise always include blank
    # so the user can choose not to use a Realm on this host
    return unless (SETTINGS[:unattended] == true) && @host.managed
    realms = accessible_resource(f.object, :realm)
    return unless realms.present?
    select_f(f, :realm_id,
                realms,
                :id, :to_label,
                { :include_blank => true,
                  :disable_button => can_override ? _(INHERIT_TEXT) : nil,
                  :disable_button_enabled => override && !explicit_value?(:realm_id),
                  :user_set => user_set?(:realm_id)
                },
                { :help_inline   => :indicator }
            ).html_safe
  end

  def host_puppet_environment_field(form, select_options = {}, html_options = {})
    select_options = {
      :include_blank => true,
      :disable_button => _(INHERIT_TEXT),
      :disable_button_enabled => inherited_by_default?(:environment_id, @host),
      :user_set => user_set?(:environment_id)}.deep_merge(select_options)

    html_options = {
      :data => {
        :url => hostgroup_or_environment_selected_hosts_path,
        :host => {
          :id => @host.id
        }
      }}.deep_merge(html_options)

    puppet_environment_field(
      form,
      accessible_resource(@host, :environment),
      select_options,
      html_options)
  end

  def hostgroup_puppet_environment_field(form, select_options = {}, html_options = {})
    select_options = {
      :include_blank => blank_or_inherit_f(form, :environment)
    }.deep_merge(select_options)

    html_options = {
      :data => {
        :url => environment_selected_hostgroups_path
      }}.deep_merge(html_options)

    puppet_environment_field(
      form,
      accessible_resource(@hostgroup, :environment),
      select_options,
      html_options)
  end

  def puppet_environment_field(form, environments_choice, select_options = {}, html_options = {})
    html_options = {
      :onchange => 'update_puppetclasses(this)',
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
    classes_ids = classes.reorder('').pluck('puppetclasses.id')
    smart_vars = VariableLookupKey.reorder('').where(:puppetclass_id => classes_ids).uniq.pluck(:puppetclass_id)
    class_vars = PuppetclassLookupKey.reorder('').joins(:environment_classes).where(:environment_classes => { :puppetclass_id => classes_ids }).uniq.pluck('environment_classes.puppetclass_id')
    klasses    = (smart_vars + class_vars).uniq

    classes.where(:id => klasses)
  end

  def puppetclasses_tab(puppetclasses_receiver)
    return unless accessible_puppet_proxies(puppetclasses_receiver).present?
    content_tag(:div, :class => 'tab-pane', :id => 'puppet_klasses') do
      if @environment.present? ||
          @hostgroup.present? && @hostgroup.environment.present?
        render 'puppetclasses/class_selection', :obj => puppetclasses_receiver
      else
        alert(:class => 'alert-info', :header => _('Notice'),
              :text => _('Please select an environment first'))
      end
    end
  end
end
