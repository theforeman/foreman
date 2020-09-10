module Resolvers
  module User
    class Current < ::Resolvers::BaseResolver
      type ::Types::User, null: true

      def resolve
        context[:current_user]
      end
    end
  end
end
