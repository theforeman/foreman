module HostsAndHostgroupsHelper
  def hostgroup_name(hostgroup, max_length = 1000)
    return if hostgroup.blank?
    options = (hostgroup.label.to_s.size > max_length) ? {:'data-original-title'=> hostgroup.label, :rel=>'twipsy'} : {}
    nesting = hostgroup.label.to_s.gsub(/[^\/]+\/?$/, "")
    nesting = truncate(nesting, :length => max_length - hostgroup.name.to_s.size) if nesting.to_s.size > 0
    name =  truncate(hostgroup.name, :length => max_length - nesting.to_s.size)
    link_to_if_authorized(
        content_tag(:span,
            content_tag(:span, nesting, :class => "gray") + name, options),
        hash_for_edit_hostgroup_path(:id => hostgroup))
  end

  def model_name host
    name = host.try(:model)
    name = host.compute_resource.name if host.compute_resource
    trunc(name, 14)
  end

  def accessible_hostgroups
    hg = (User.current.hostgroups.any? and !User.current.admin?) ? User.current.hostgroups : Hostgroup.all
    hg.sort{ |l, r| l.to_label <=> r.to_label }
  end

  def parent_classes obj
    return obj.hostgroup.classes if obj.kind_of?(Host::Base) and obj.hostgroup
    return obj.is_root? ? [] : obj.parent.classes if obj.is_a?(Hostgroup)
    []
  end

  def accessible_domains
    (User.current.domains.any? and !User.current.admin?) ? User.current.domains : Domain.all
  end

  def domain_subnets
    return [] if @domain.blank?
    @domain.subnets
  end

  def arch_oss
    return [] if @architecture.blank?
    @architecture.operatingsystems
  end

  def os_media
    return [] if @operatingsystem.blank?
    @operatingsystem.media
  end

  def os_ptable
    return [] if @operatingsystem.blank?
    @operatingsystem.ptables
  end

  def puppet_master_fields f
    "#{puppet_ca(f)} #{puppet_master(f)}".html_safe
  end

  def puppet_ca f
    # Don't show this if we have no CA proxies, otherwise always include blank
    # so the user can choose not to sign the puppet cert on this host
    proxies = SmartProxy.puppetca_proxies
    return if proxies.count == 0
    select_f f, :puppet_ca_proxy_id, proxies, :id, :name,
             { :include_blank => true },
             { :label       => _("Puppet CA"),
               :help_inline => _("Use this puppet server as a CA server") }
  end

  def puppet_master f
    # Don't show this if we have no Puppet proxies, otherwise always include blank
    # so the user can choose not to use puppet on this host
    proxies = SmartProxy.puppet_proxies
    return if proxies.count == 0
    select_f f, :puppet_proxy_id, proxies, :id, :name,
             { :include_blank => true },
             { :label       => _("Puppet Master"),
               :help_inline => _("Use this puppet server as an initial Puppet Server or to execute puppet runs") }
  end

  def interesting_klasses obj
    classes    = obj.all_puppetclasses
    smart_vars = LookupKey.reorder('').where(:puppetclass_id => classes.map(&:id)).group(:puppetclass_id).count
    class_vars = LookupKey.reorder('').joins(:environment_classes).where(:environment_classes => { :puppetclass_id => classes.map(&:id) }).group('environment_classes.puppetclass_id').count
    klasses    = smart_vars.keys + class_vars.keys

    classes.select { |pc| klasses.include?(pc.id) }
  end

  def ifs_bmc_opts obj
    case obj.read_attribute(:type)
      when "Nic::BMC"
        {}
      else
        { :disabled => true, :value => nil }
    end
  end

end
