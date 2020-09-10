class InterfaceTypeMapper
  class UnknownTypeException < Foreman::Exception; end

  DEFAULT_TYPE = Nic::Managed
  ALLOWED_TYPE_NAMES = Nic::Base.allowed_types.map { |t| t.humanized_name.downcase }
  LEGACY_TYPE_NAMES = Nic::Base.allowed_types.map { |t| t.name }

  def self.map(nic_type)
    return DEFAULT_TYPE.name if nic_type.nil?

    if ALLOWED_TYPE_NAMES.include? nic_type
      # convert human readable name to the NIC's class name
      Nic::Base.type_by_name(nic_type).to_s
    elsif LEGACY_TYPE_NAMES.include? nic_type
      # enable sending class names directly to keep backward compatibility
      nic_type
    else
      raise UnknownTypeException.new(N_("Unknown interface type, must be one of [%s]") % ALLOWED_TYPE_NAMES.join(', '))
    end
  end
end
