module HostsAndHostgroupsHelper
  include AncestryHelper

  def model_name(host)
    name = host.try(:model)
    name = host.compute_resource.name if host.compute_resource
    name
  end

  def accessible_resource_records(resource, order = :name)
    klass = resource.to_s.classify.constantize
    klass = klass.with_taxonomy_scope_override(@location, @organization) if klass.include? Taxonomix
    klass.authorized.reorder(order)
  end

  def accessible_resource(obj, resource, order = :name)
    list = accessible_resource_records(resource, order).to_a
    # we need to allow the current value even if it was filtered
    current = obj.public_send(resource) if obj.respond_to?(resource)
    list |= [current] if current.present?
    list
  end

  def accessible_related_resource(obj, relation, opts = {})
    return [] if obj.blank?
    order = opts.fetch(:order, :name)
    where = opts.fetch(:where, nil)
    related = obj.public_send(relation)
    related = related.with_taxonomy_scope_override(@location, @organization) if obj.class.reflect_on_association(relation).klass.include?(Taxonomix)
    related.authorized.where(where).reorder(order)
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

  def puppet_master_fields(f, can_override = false, override = false)
    "#{puppet_ca(f, can_override, override)} #{puppet_master(f, can_override, override)}".html_safe
  end

  INHERIT_TEXT = N_("inherit")

  def puppet_ca(f, can_override, override)
    # Don't show this if we have no CA proxies, otherwise always include blank
    # so the user can choose not to sign the puppet cert on this host
    proxies = accessible_puppet_ca_proxies(f.object)
    return unless proxies.present?
    select_f f, :puppet_ca_proxy_id, proxies, :id, :name,
             { :include_blank => blank_or_inherit_f(f, :puppet_ca_proxy),
               :disable_button => can_override ? _(INHERIT_TEXT) : nil,
               :disable_button_enabled => override && !explicit_value?(:puppet_ca_proxy_id),
               :user_set => user_set?(:puppet_ca_proxy_id)
             },
             { :label       => _("Puppet CA"),
               :help_inline => _("Use this puppet server as a CA server") }
  end

  def puppet_master(f, can_override, override)
    # Don't show this if we have no Puppet proxies, otherwise always include blank
    # so the user can choose not to use puppet on this host
    proxies = accessible_puppet_proxies(f.object)
    return unless proxies.present?
    select_f f, :puppet_proxy_id, proxies, :id, :name,
             { :include_blank => blank_or_inherit_f(f, :puppet_proxy),
               :disable_button => can_override ? _(INHERIT_TEXT) : nil,
               :disable_button_enabled => override && !explicit_value?(:puppet_proxy_id),
               :user_set => user_set?(:puppet_proxy_id)

             },
             { :label       => _("Puppet Master"),
               :help_inline => _("Use this puppet server as an initial Puppet Server or to execute puppet runs") }
  end

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

  def explicit_value?(field)
    return true if params[:action] == 'clone'
    return false unless params[:host]
    !!params[:host][field]
  end

  def user_set?(field)
    # if the host has no hostgroup
    return true unless @host && @host.hostgroup
    # when editing a host, the values are specified explicitly
    return true if params[:action] == 'edit'
    return true if params[:action] == 'clone'
    # check if the user set the field explicitly despite setting a hostgroup.
    params[:host] && params[:host][:hostgroup_id] && params[:host][field]
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
