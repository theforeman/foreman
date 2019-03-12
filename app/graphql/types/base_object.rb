module Types
  class BaseObject < GraphQL::Types::Relay::BaseObject
    def self.timestamps
      field :created_at, GraphQL::Types::ISO8601DateTime, null: true
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
    end
  end
end
