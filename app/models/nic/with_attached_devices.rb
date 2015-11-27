module Nic::WithAttachedDevices
  extend ActiveSupport::Concern

  SEPARATOR = ','
  included do
    alias_method_chain :enc_attributes, :attached_devices
    validates :attached_devices, :format => { :with => /\A[a-z0-9#{SEPARATOR}.:_-]+\Z/ }, :allow_blank => true
    validates :identifier, :presence => true, :if => :managed?

    before_validation :ensure_virtual

    register_to_enc_transformation :type, ->(type) { type.constantize.humanized_name }
  end

  def virtual
    true
  end
  alias_method :virtual?, :virtual

  def attached_devices=(devices)
    devices = devices.split(SEPARATOR) if devices.is_a?(String)
    super(devices.map { |i| i.downcase.strip }.join(SEPARATOR))
  end

  def attached_devices_identifiers
    attached_devices.split(SEPARATOR)
  end

  def add_device(identifier)
    self.attached_devices = attached_devices_identifiers.push(identifier).uniq.join(SEPARATOR)
  end

  def remove_device(identifier)
    self.attached_devices = attached_devices_identifiers.tap { |a| a.delete(identifier) }.join(SEPARATOR)
  end

  private

  def ensure_virtual
    self.virtual = true
  end

  def enc_attributes_with_attached_devices
    @enc_attributes = enc_attributes_without_attached_devices + ['attached_devices']
  end
end
