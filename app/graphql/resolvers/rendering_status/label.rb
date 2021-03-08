module Resolvers
  module RenderingStatus
    class Label < Resolvers::BaseResolver
      type String, null: false

      def resolve
        HostStatus::RenderingStatus::LABELS.fetch(object.status, N_('Unknown'))
      end
    end
  end
end
