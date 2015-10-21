module HostsAndHostgroupsHelper
  include AncestryHelper

  def model_name(host)
    name = host.try(:model)
    name = host.compute_resource.name if host.compute_resource
    name
  end

  def accessible_hostgroups
    Hostgroup.with_taxonomy_scope_override(@location,@organization).order(:title)
  end

  def parent_classes(obj)
    return obj.hostgroup.classes if obj.is_a?(Host::Base) and obj.hostgroup
    return obj.is_root? ? [] : obj.parent.classes if obj.is_a?(Hostgroup)
    []
  end

  def accessible_domains
    Domain.with_taxonomy_scope_override(@location,@organization).order(:name)
  end

  def accessible_subnets
    Subnet.with_taxonomy_scope_override(@location,@organization).order(:name)
  end

  def domain_subnets(domain = @domain)
    return [] if domain.blank?
    ids = domain.subnets.pluck('subnets.id')
    accessible_subnets.where('subnets.id' => ids)
  end

  def arch_oss
    return [] if @architecture.blank?
    @architecture.operatingsystems
  end

  def os_media
    return [] if @operatingsystem.blank?
    @operatingsystem.media.with_taxonomy_scope(@location,@organization,:path_ids)
  end

  def os_ptable
    return [] if @operatingsystem.blank?
    @operatingsystem.ptables
  end

  def puppet_master_fields(f, can_override = false, override = false)
    "#{puppet_ca(f, can_override, override)} #{puppet_master(f, can_override, override)}".html_safe
  end

  INHERIT_TEXT = N_("inherit")

  def puppet_ca(f, can_override, override)
    # Don't show this if we have no CA proxies, otherwise always include blank
    # so the user can choose not to sign the puppet cert on this host
    proxies = SmartProxy.unscoped.with_features("Puppet CA").with_taxonomy_scope(@location,@organization,:path_ids)
    return if proxies.count == 0
    select_f f, :puppet_ca_proxy_id, proxies, :id, :name,
             { :include_blank => blank_or_inherit_f(f, :puppet_ca_proxy),
               :disable_button => can_override ? _(INHERIT_TEXT) : nil,
               :disable_button_enabled => override && !explicit_value?(:puppet_ca_proxy_id),
               :user_set => params[:host] && params[:host][:puppet_ca_proxy_id]
             },
             { :label       => _("Puppet CA"),
               :help_inline => _("Use this puppet server as a CA server") }
  end

  def puppet_master(f, can_override, override)
    # Don't show this if we have no Puppet proxies, otherwise always include blank
    # so the user can choose not to use puppet on this host
    proxies = SmartProxy.unscoped.with_features("Puppet").with_taxonomy_scope(@location,@organization,:path_ids)
    return if proxies.count == 0
    select_f f, :puppet_proxy_id, proxies, :id, :name,
             { :include_blank => blank_or_inherit_f(f, :puppet_proxy),
               :disable_button => can_override ? _(INHERIT_TEXT) : nil,
               :disable_button_enabled => override && !explicit_value?(:puppet_proxy_id),
               :user_set => params[:host] && params[:host][:puppet_proxy_id]

             },
             { :label       => _("Puppet Master"),
               :help_inline => _("Use this puppet server as an initial Puppet Server or to execute puppet runs") }
  end

  def realm_field(f, can_override = false, override = false)
    # Don't show this if we have no Realms, otherwise always include blank
    # so the user can choose not to use a Realm on this host
    return if Realm.count == 0
    return unless (SETTINGS[:unattended] == true) && @host.managed
    select_f(f, :realm_id,
                Realm.with_taxonomy_scope_override(@location, @organization).authorized(:view_realms),
                :id, :to_label,
                { :include_blank => true,
                  :disable_button => can_override ? _(INHERIT_TEXT) : nil,
                  :disable_button_enabled => override && !explicit_value?(:realm_id),
                  :user_set => params[:host] && params[:host][:realm_id]
                },
                { :help_inline   => :indicator }
            ).html_safe
  end

  def interesting_puppetclasses(obj)
    classes    = obj.all_puppetclasses
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
end
