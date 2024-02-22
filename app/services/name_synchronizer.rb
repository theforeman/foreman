class NameSynchronizer
  def initialize(object)
    case object
    when Host::Base
      @host = object
      @interface = @host.primary_interface
    when Nic::Base
      @interface = object
      @host = @interface.host
    else
      raise ArgumentError, 'unsupported object, not kind of Host::Base or Nic::Base'
    end
  end

  # we always write interface name to host (one-way sync only)
  # we have to use write_attribute, since host#name= is delegated to primary interface
  # which triggers the sync
  def sync_name
    @host.send :write_attribute, :name, interface_name
  end

  def sync_required?
    @interface.primary? && @host.present? && (@host.name != interface_name)
  end

  private

  def interface_name
    @interface.name
  end
end
