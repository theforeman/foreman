module Mutations
  module Concerns
    module TaxonomyArgs
      extend ActiveSupport::Concern

      included do
        argument :organization_ids, [GraphQL::Types::ID], loads: Types::Organization
        argument :location_ids, [GraphQL::Types::ID], loads: Types::Location
      end
    end
  end
end
