module Types
  class ProviderFriendlyNameEnum < Types::BaseEnum
    ::ComputeResource.all_providers.values.each do |class_name|
      provider_friendly_name = class_name.constantize.provider_friendly_name
      value provider_friendly_name.tr(' ', '_'), provider_friendly_name
    end
  end
end
