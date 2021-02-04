module Connections
  class BaseConnection < GraphQL::Types::Relay::BaseConnection
    field :total_count, Integer, null: false
    field :records_count, Integer, null: false

    def total_count
      object.nodes.size
    end

    def records_count
      object.nodes.empty? ? 0 : object.nodes.first.class.count
    end
  end
end
