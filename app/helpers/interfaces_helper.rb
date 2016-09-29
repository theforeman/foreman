module InterfacesHelper
  def interfaces_types
    @types ||= Nic::Base.allowed_types.collect do |nic_type|
      [_(nic_type.humanized_name), nic_type]
    end
  end
end
