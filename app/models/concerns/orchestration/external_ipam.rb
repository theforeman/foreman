module Orchestration::ExternalIPAM
  extend ActiveSupport::Concern
  include Orchestration::Common
  include SubnetsHelper

  included do
    after_validation :queue_external_ipam
    before_destroy :queue_external_ipam_destroy
  end

  def generate_external_ipam_task_id(action, interface = self)
    id = [interface.mac, interface.ip, interface.identifier, interface.id].find {|x| x&.present?}
    "external_ipam_#{action}_#{id}"
  end

  protected

  def set_external_ip
    if ip_available?
      response = subnet.external_ipam_proxy.add_ip_to_subnet(ip, subnet)
      success?(response, 'Address created')
    else
      self.errors.add :ip, _('This IP address has already been reserved in External IPAM')
      self.errors.add :interfaces, _('Some interfaces are invalid')
    end
  end

  # Empty method for rollbacks. We don't want to delete IP's from IPAM when there
  # is a conflict(i.e. IP address already taken)
  def del_external_ip
  end

  def remove_external_ip
    response = subnet.external_ipam_proxy.delete_ip_from_subnet(ip, subnet)
    success?(response, 'Address deleted')
  end

  def requires_update?
    return false if new_record?
    old.ip != self.ip
  end

  def requires_delete?
    old = Nic::Base.find(id)
    !old.ip.nil? && !old.subnet_id.nil?
  end

  def ip_available?
    response = subnet.external_ipam_proxy.ip_exists(ip, subnet)
    success?(response, 'No addresses found')
  end

  def success?(response, message)
    (response['message'] && response['message'] == message) ? true : false
  end

  private

  def queue_external_ipam
    new_record? ? queue_external_ipam_create : queue_external_ipam_update
  end

  def queue_external_ipam_create
    return unless external_ipam?(subnet) && errors.empty?
    logger.debug "Scheduling new IP reservation in external IPAM for #{self}"
    queue.create(id: generate_external_ipam_task_id("create"), name: _("Creating IP in External IPAM for %s") % self, priority: 10, action: [self, :set_external_ip]) if external_ipam?(subnet)
    true
  end

  def queue_external_ipam_destroy
    return unless external_ipam?(subnet) && errors.empty?
    logger.debug "Removing IP reservation in external IPAM for #{self}"
    queue.create(id: generate_external_ipam_task_id("remove"), name: _("Removing IP in External IPAM for %s") % self, priority: 5, action: [self, :remove_external_ip]) if external_ipam?(subnet) && requires_delete?
    true
  end

  def queue_external_ipam_update
    return unless external_ipam?(subnet) && errors.empty?
    if requires_update?
      logger.debug "Updating IP reservation in external IPAM for #{self}"
      queue.create(id: generate_external_ipam_task_id("remove"), name: _("Removing IP in External IPAM for %s") % self, priority: 5, action: [old, :remove_external_ip]) if external_ipam?(subnet) && requires_delete?
      queue.create(id: generate_external_ipam_task_id("create"), name: _("Creating IP in External IPAM for %s") % self, priority: 10, action: [self, :set_external_ip]) if external_ipam?(subnet)
    end
    true
  end
end
