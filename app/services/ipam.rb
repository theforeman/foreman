module IPAM
  MODES = {:dhcp => N_('DHCP'), :db => N_('Internal DB'), :random_db => N_('Random DB'), :eui64 => N_('EUI-64'), :none => N_('None')}

  def self.new(type, *args)
    case type
    when IPAM::MODES[:none]
      IPAM::None.new(*args)
    when IPAM::MODES[:dhcp]
      IPAM::Dhcp.new(*args)
    when IPAM::MODES[:db]
      IPAM::Db.new(*args)
    when IPAM::MODES[:random_db]
      IPAM::RandomDb.new(*args)
    when IPAM::MODES[:eui64]
      IPAM::Eui64.new(*args)
    else
      raise ::Foreman::Exception.new(N_("Unknown IPAM type - can't continue"))
    end
  end
end
