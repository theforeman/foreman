module Types
  class ComputeResource < BaseObject
    description 'A ComputeResource'

    global_id_field :id
    timestamps
    field :name, String
    field :description, String
    field :url, String
    field :provider, Types::ProviderEnum
    field :provider_friendly_name, Types::ProviderFriendlyNameEnum

    has_many :compute_attributes, Types::ComputeAttribute
    has_many :hosts, Types::Host
    has_many :networks, Types::Networks::Union, resolver: Resolvers::ComputeResource::Networks

    def provider_friendly_name
      object.provider_friendly_name.tr(' ', '_')
    end
  end
end
