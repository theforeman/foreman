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
  end
end
