module Types
  class ProviderEnum < Types::BaseEnum
    def self.enum_values(context = {})
      ::ComputeResource.all_providers.keys.map do |provider|
        GraphQL::Schema::EnumValue.new(provider, owner: self)
      end
    end
  end
end
