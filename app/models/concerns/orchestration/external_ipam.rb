module Orchestration::ExternalIPAM
  extend ActiveSupport::Concern
  include Orchestration::Common
  include SubnetsHelper

  included do
    after_validation :queue_external_ipam
    before_destroy :queue_external_ipam_destroy
  end

  def generate_external_ipam_task_id(action, network_type, interface = self)
    id = [interface.mac, interface.ip, interface.identifier, interface.id].find { |x| x&.present? }
    "external_ipam_#{action}_#{id}_#{network_type}"
  end

  protected

  def set_add_external_ip(params)
    ip, subnet = params[:ip], params[:subnet]

    if ip_is_available?(ip, subnet)
      subnet.external_ipam_proxy.add_ip_to_subnet(ip, subnet.network_address, subnet.externalipam_group)
    else
      errors.add :ip, _('This IP address has already been reserved in External IPAM') if subnet.network_type == "IPv4"
      errors.add :ip6, _('This IP address has already been reserved in External IPAM') if subnet.network_type == "IPv6"
      errors.add :interfaces, _('Some interfaces are invalid')
    end
  end

  def set_remove_external_ip(params)
    ip, subnet = params[:ip], params[:subnet]
    subnet.external_ipam_proxy.delete_ip_from_subnet(ip, subnet.network_address, subnet.externalipam_group)
  end

  def del_add_external_ip(params)
    new_record? ? rollback_on_add : rollback_on_update
  end

  def del_remove_external_ip(params)
    logger.warn "IP address deletion failed in External IPAM, and it cannot be compensated."
  end

  def rollback_on_add
    if ipv4_errors_not_ipv6? && !ip_is_available?(ip6, subnet6)
      subnet.external_ipam_proxy.delete_ip_from_subnet(ip6, subnet6.network_address, subnet6.externalipam_group)
    elsif ipv6_errors_not_ipv4? && !ip_is_available?(ip, subnet)
      subnet.external_ipam_proxy.delete_ip_from_subnet(ip, subnet.network_address, subnet.externalipam_group)
    end
  end

  def rollback_on_update
    if ipv4_errors_not_ipv6? && ip_is_available?(old.ip, old.subnet)
      subnet.external_ipam_proxy.add_ip_to_subnet(old.ip, old.subnet.network_address, old.subnet.externalipam_group)
    elsif ipv6_errors_not_ipv4? && ip_is_available?(old.ip6, old.subnet6)
      subnet.external_ipam_proxy.add_ip_to_subnet(old.ip6, old.subnet6.network_address, old.subnet6.externalipam_group)
    end
  end

  def requires_update?
    return false if new_record?
    old.ip != ip
  end

  def requires_update6?
    return false if new_record?
    old.ip6 != ip6
  end

  def requires_delete?
    old_nic = Nic::Base.find(id)
    !old_nic.ip.nil? && !old_nic.subnet_id.nil?
  end

  def requires_delete6?
    old_nic = Nic::Base.find(id)
    !old_nic.ip6.nil? && !old_nic.subnet6_id.nil?
  end

  def ip_is_available?(ip, subnet)
    !subnet.external_ipam_proxy.ip_exists(ip, subnet.network_address, subnet.externalipam_group)
  end

  def ipv4_errors_not_ipv6?
    !errors[:ip].empty? && errors[:ip6].empty? && ip6.present?
  end

  def ipv6_errors_not_ipv4?
    !errors[:ip6].empty? && errors[:ip].empty? && ip.present?
  end

  def ipv4_removed?
    old.ip.present? && ip.blank?
  end

  def ipv6_removed?
    old.ip6.present? && ip6.blank?
  end

  def ipv4_added?
    old.ip.blank? && ip.present?
  end

  def ipv6_added?
    old.ip6.blank? && ip6.present?
  end

  def ipv4_changed?
    old.ip.present? && ip.present? && old.ip != ip
  end

  def ipv6_changed?
    old.ip6.present? && ip6.present? && old.ip6 != ip6
  end

  private

  def queue_external_ipam
    new_record? ? queue_external_ipam_create : queue_external_ipam_update
  end

  def queue_external_ipam_create
    return unless (external_ipam?(subnet) || external_ipam?(subnet6)) && errors.empty?
    logger.debug "Scheduling new IP reservation(s) in external IPAM for #{self}"
    queue.create(id: generate_external_ipam_task_id("create", subnet.network_type), name: _("Creating IPv4 in External IPAM for %s") % self, priority: 10, action: [self, :set_add_external_ip, {:ip => ip, :subnet => subnet}]) if ip.present? && subnet.present? && external_ipam?(subnet)
    queue.create(id: generate_external_ipam_task_id("create", subnet6.network_type), name: _("Creating IPv6 in External IPAM for %s") % self, priority: 10, action: [self, :set_add_external_ip, {:ip => ip6, :subnet => subnet6}]) if ip6.present? && subnet6.present? && external_ipam?(subnet6)
    true
  end

  def queue_external_ipam_destroy
    return unless (external_ipam?(subnet) || external_ipam?(subnet6)) && errors.empty?
    logger.debug "Removing IP reservation(s) in external IPAM for #{self}"
    queue.create(id: generate_external_ipam_task_id("remove", "IPv4"), name: _("Removing IPv4 in External IPAM for %s") % self, priority: 5, action: [self, :set_remove_external_ip, {:ip => ip, :subnet => subnet}]) if requires_delete? && external_ipam?(subnet)
    queue.create(id: generate_external_ipam_task_id("remove", "IPv6"), name: _("Removing IPv6 in External IPAM for %s") % self, priority: 5, action: [self, :set_remove_external_ip, {:ip => ip6, :subnet => subnet6}]) if requires_delete6? && external_ipam?(subnet6)
    true
  end

  def queue_external_ipam_update
    return false if old.nil?
    return unless (external_ipam?(subnet) || external_ipam?(subnet6) || external_ipam?(old.subnet) || external_ipam?(old.subnet6)) && errors.empty?
    logger.debug "Updating IP reservation in external IPAM for #{self}"
    queue.create(id: generate_external_ipam_task_id("create", subnet.network_type), name: _("Creating IPv4 in External IPAM for %s") % self, priority: 10, action: [self, :set_add_external_ip, {:ip => ip, :subnet => subnet}]) if (ipv4_added? || ipv4_changed?) && external_ipam?(subnet)
    queue.create(id: generate_external_ipam_task_id("remove", old.subnet.network_type), name: _("Removing IPv4 in External IPAM for %s") % self, priority: 5, action: [old, :set_remove_external_ip, {:ip => old.ip, :subnet => old.subnet}]) if (ipv4_removed? || ipv4_changed?) && external_ipam?(old.subnet)
    queue.create(id: generate_external_ipam_task_id("create", subnet6.network_type), name: _("Creating IPv6 in External IPAM for %s") % self, priority: 10, action: [self, :set_add_external_ip, {:ip => ip6, :subnet => subnet6}]) if (ipv6_added? || ipv6_changed?) && external_ipam?(subnet6)
    queue.create(id: generate_external_ipam_task_id("remove", old.subnet6.network_type), name: _("Removing IPv6 in External IPAM for %s") % self, priority: 5, action: [old, :set_remove_external_ip, {:ip => old.ip6, :subnet => old.subnet6}]) if (ipv6_removed? || ipv6_changed?) && external_ipam?(old.subnet6)
    true
  end
end
