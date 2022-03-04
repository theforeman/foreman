module Resolvers
  module Concerns
    module Association
      extend ActiveSupport::Concern

      # In future versions of graphql-ruby (>1.9) we should have easier access through `field.owner`
      def owner_type
        object.class.graphql_type&.safe_constantize
      end

      def record
        if owner_type
          owner_type.record_for(object)
        else
          object
        end
      end

      def resolve
        CollectionLoader.for(self.class::MODEL_CLASS, self.class::ASSOC_NAME).load(record)
      end
    end
  end
end
