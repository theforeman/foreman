module Resolvers
  module Concerns
    module Collection
      extend ActiveSupport::Concern

      included do
        type ["Types::#{self::MODEL_CLASS}".safe_constantize], null: false

        argument :search, String, 'Search query', required: false
        argument :order_by, String, 'Order by this field', required: false
        argument :order, String, 'Order direction', required: false
      end

      def resolve(search: nil, order: nil, order_by: nil)
        params = {
          order_by: order_by,
          order: order,
          search: search
        }

        Queries::AuthorizedModelQuery.new(
          model_class: self.class::MODEL_CLASS,
          user: context[:current_user]
        ).results(params)
      end
    end
  end
end
