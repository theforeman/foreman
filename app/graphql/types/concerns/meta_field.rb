module Types
  module Concerns
    module MetaField
      extend ActiveSupport::Concern

      included do
        field :meta, ::Types::Meta, resolve: (proc do |object|
          {
            :can_edit => ::User.current.can?(object.permission_name(:edit), object),
            :can_destroy => ::User.current.can?(object.permission_name(:destroy), object),
          }
        end)
      end
    end
  end
end
