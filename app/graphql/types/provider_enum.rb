module Types
  class ProviderEnum < Types::BaseEnum
    ::ComputeResource.supported_providers.keys.each do |provider|
      value provider
    end
  end
end
