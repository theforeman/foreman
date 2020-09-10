module Resolvers
  module Host
    class Path < Resolvers::BaseResolver
      type String, null: false

      def resolve
        Rails.application.routes.url_helpers.host_path(object)
      end
    end
  end
end
