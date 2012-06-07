module HostsAndHostgroupsHelper
  def hostgroup_name group, max_length = 1000
    return if group.blank?
    options = (group.to_s.size > max_length) ? {:'data-original-title'=> group.to_s, :rel=>'twipsy'} : {}
    nesting = group.to_s.gsub(group.name, "")
    nesting = truncate(nesting, :length => max_length - group.name.size) if nesting.size > 0
    name =  truncate(group.name.to_s, :length => max_length - nesting.size)
    link_to_if_authorized(
        content_tag(:span,
            content_tag(:span, nesting, :class => "gray") + name, options),
        hash_for_edit_hostgroup_path(:id => group))
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
    return obj.hostgroup.classes if obj.is_a?(Host) and obj.hostgroup
    return obj.is_root? ? [] : obj.parent.classes if obj.is_a?(Hostgroup)
    []
  end

  def select_hypervisor item
    options_for_select Hypervisor.all.map{|h| [h.name, h.id]}, item.try(:hypervisor_id).try(:to_i)
  end

  def select_memory item = nil
    memory = item.try(:memory) if item
    memory ||= @guest.memory if @guest
    options_for_select Hypervisor::MEMORY_SIZE.map {|mem| [number_to_human_size(mem*1024), mem]}, memory.to_i
  end

  def volume_size item
    return item.disk_size if item.try(:disk_size)
    return @guest.volume.size if @guest
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
    ca      = SmartProxy.joins(:features).where(:features => { :name => "Puppet CA" })
    proxies = SmartProxy.joins(:features).where(:features => { :name => "Puppet" })
    # do not show the ca proxy, if we have only one of those and its the same as the puppet proxy
    fields =  puppet_ca(f) unless ca.count == 1 and ca.map(&:id) == proxies.map(&:id)
    "#{fields} #{puppet_master(f)}".html_safe
  end

  def puppet_ca f
    # if we are not using provisioning, not much point in presenting the CA option (assuming your CA is already set otherwise)
    return unless SETTINGS[:unattended]
    proxies = SmartProxy.joins(:features).where(:features => { :name => "Puppet CA" })
    select_f f, :puppet_ca_proxy_id, proxies, :id, :name,
             { :include_blank => proxies.count > 1 },
             { :label       => "Puppet CA",
               :help_inline => "Use this puppet server as a CA server" }
  end

  def puppet_master f
    proxies = SmartProxy.joins(:features).where(:features => { :name => "Puppet" })
    select_f f, :puppet_proxy_id, proxies, :id, :name,
             { :include_blank => proxies.count > 1 },
             { :label       => "Puppet Master",
               :help_inline => "Use this puppet server as an initial Puppet Server or to execute puppet runs" }
  end

end
