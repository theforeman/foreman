module Nic::WithAttachedDevices
  extend ActiveSupport::Concern
  include Exportable

  SEPARATOR = ','
  included do
    validates :attached_devices, :format => { :with => /\A[A-Za-z0-9#{SEPARATOR}.:_-]+\Z/ }, :allow_blank => true
    validates :identifier, :presence => true, :if => :managed?

    before_validation :ensure_virtual
    attr_exportable :attached_devices
  end

  def virtual
    true
  end
  alias_method :virtual?, :virtual

  def attached_devices=(devices)
    devices = devices.split(SEPARATOR) if devices.is_a?(String)
    super(devices.map { |i| i.strip }.join(SEPARATOR))
  end

  def attached_devices_identifiers
    attached_devices.split(SEPARATOR)
  end

  def children_mac_addresses
    attached_devices_objects.map(&:mac)
  end

  def add_device(identifier)
    self.attached_devices = attached_devices_identifiers.push(identifier).uniq.join(SEPARATOR)
  end

  def remove_device(identifier)
    self.attached_devices = attached_devices_identifiers.tap { |a| a.delete(identifier) }.join(SEPARATOR)
  end

  def attached_devices_objects
    host.interfaces.select { |i| attached_devices_identifiers.include?(i.identifier) }
  end

  private

  def ensure_virtual
    self.virtual = true
  end
end
