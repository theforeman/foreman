module HostsAndHostgroupsHelper
  include AncestryHelper

  def model_name(host)
    name = host.try(:model)
    name = host.compute_resource.name if host.compute_resource
    trunc_with_tooltip(name, 14)
  end

  def accessible_hostgroups
    hg = Hostgroup.with_taxonomy_scope_override(@location,@organization)
    hg.sort{ |l, r| l.to_label <=> r.to_label }
  end

  def parent_classes(obj)
    return obj.hostgroup.classes if obj.kind_of?(Host::Base) and obj.hostgroup
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

  def puppet_master_fields(f)
    "#{puppet_ca(f)} #{puppet_master(f)}".html_safe
  end

  def puppet_ca(f)
    # Don't show this if we have no CA proxies, otherwise always include blank
    # so the user can choose not to sign the puppet cert on this host
    proxies = SmartProxy.unscoped.with_features("Puppet CA").with_taxonomy_scope(@location,@organization,:path_ids)
    return if proxies.count == 0
    select_f f, :puppet_ca_proxy_id, proxies, :id, :name,
             { :include_blank => blank_or_inherit_f(f, :puppet_ca_proxy) },
             { :label       => _("Puppet CA"),
               :help_inline => _("Use this puppet server as a CA server") }
  end

  def puppet_master(f)
    # Don't show this if we have no Puppet proxies, otherwise always include blank
    # so the user can choose not to use puppet on this host
    proxies = SmartProxy.unscoped.with_features("Puppet").with_taxonomy_scope(@location,@organization,:path_ids)
    return if proxies.count == 0
    select_f f, :puppet_proxy_id, proxies, :id, :name,
             { :include_blank => blank_or_inherit_f(f, :puppet_proxy) },
             { :label       => _("Puppet Master"),
               :help_inline => _("Use this puppet server as an initial Puppet Server or to execute puppet runs") }
  end

  def realm_field(f)
    # Don't show this if we have no Realms, otherwise always include blank
    # so the user can choose not to use a Realm on this host
    return if Realm.count == 0
    return unless (SETTINGS[:unattended] == true) && @host.managed
    select_f(f, :realm_id,
                Realm.with_taxonomy_scope_override(@location, @organization).authorized(:view_realms),
                :id, :to_label,
                { :include_blank => true },
                { :help_inline   => :indicator }
            ).html_safe
  end

  def interesting_klasses(obj)
    classes    = obj.all_puppetclasses
    smart_vars = LookupKey.reorder('').where(:puppetclass_id => classes.map(&:id)).group(:puppetclass_id).count
    class_vars = LookupKey.reorder('').joins(:environment_classes).where(:environment_classes => { :puppetclass_id => classes.map(&:id) }).group('environment_classes.puppetclass_id').count
    klasses    = smart_vars.keys + class_vars.keys

    classes.select { |pc| klasses.include?(pc.id) }
  end

end
