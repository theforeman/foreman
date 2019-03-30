module Types
  class InterfaceTypeEnum < Types::BaseEnum
    Nic::Base.allowed_types.each do |type|
      value type.humanized_name.downcase
    end
  end
end
