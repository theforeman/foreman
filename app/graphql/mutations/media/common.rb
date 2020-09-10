module Mutations
  module Media
    module Common
      extend ActiveSupport::Concern

      included do
        argument :name, String
        argument :path, String
        argument :os_family, Types::OsFamilyEnum
        argument :operatingsystem_ids, [GraphQL::Types::ID], loads: Types::Operatingsystem, required: false

        include ::Mutations::Concerns::TaxonomyArgs

        field :medium, Types::Medium, 'The installation medium.', null: true
      end
    end
  end
end
