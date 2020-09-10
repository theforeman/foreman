module Types
  class BaseUnion < GraphQL::Schema::Union
    connection_type_class Connections::BaseConnection
  end
end
