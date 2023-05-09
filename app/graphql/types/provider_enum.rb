module Types
  class ProviderEnum < Types::BaseEnum
    ::ComputeResource.all_providers.keys.each do |provider|
      value provider
    end
  end
end
