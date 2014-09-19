module InterfacesHelper
  def interfaces_types
    @types ||= [
      [_("Interface"), Nic::Managed],
      [_("Bond"), Nic::Bond],
      [_("BMC"), Nic::BMC]
    ]
  end
end
