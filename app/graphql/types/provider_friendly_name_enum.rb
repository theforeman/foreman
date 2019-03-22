module Types
  class ProviderFriendlyNameEnum < Types::BaseEnum
    ::ComputeResource.supported_providers.values.each do |class_name|
      value class_name.constantize.provider_friendly_name
    end
  end
end
