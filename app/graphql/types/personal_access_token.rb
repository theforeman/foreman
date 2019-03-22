module Types
  class PersonalAccessToken < BaseObject
    description 'A Personal Access Token'

    global_id_field :id
    timestamps
    field :name, String
    field :expires_at, GraphQL::Types::ISO8601DateTime
    field :last_used_at, GraphQL::Types::ISO8601DateTime
    field :revoked, Boolean, method: :revoked?
    field :expires, Boolean, method: :expires?
    field :active, Boolean, method: :active?
    field :used, Boolean, method: :used?

    belongs_to :user, Types::User
  end
end
