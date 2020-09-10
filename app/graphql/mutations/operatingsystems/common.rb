module Mutations
  module Operatingsystems
    module Common
      extend ActiveSupport::Concern

      included do
        argument :name, String
        argument :description, String, required: false
        argument :major, String, required: false
        argument :minor, String, required: false
        argument :release_name, String, required: false
        argument :family, Types::OsFamilyEnum
        argument :password_hash, Types::PasswordHashEnum

        argument :architecture_ids, [GraphQL::Types::ID], loads: Types::Architecture, required: false
        argument :medium_ids, [GraphQL::Types::ID], loads: Types::Medium, required: false, as: :media
        argument :ptable_ids, [GraphQL::Types::ID], loads: Types::Ptable, required: false

        field :operatingsystem, Types::Operatingsystem, 'The operating system', null: true
      end
    end
  end
end
