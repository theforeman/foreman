module Resolvers
  module ComputeResource
    class Networks < Resolvers::BaseResolver
      type [Types::Networks::Union], null: true

      argument :cluster_id, String, required: false

      def resolve(cluster_id: nil)
        object.available_networks(cluster_id.presence)
      end
    end
  end
end
