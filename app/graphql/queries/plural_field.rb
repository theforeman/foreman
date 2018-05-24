module Queries
  class PluralField < GraphQL::Function
    attr_reader :type

    argument(:search, types.String, 'Search query')
    argument(:orderField, types.String, 'Order field')
    argument(:orderDirection, types.String, 'Order direction')

    def initialize(model_class:, type:)
      @model_class = model_class
      @type = type
    end

    def call(_, args, ctx)
      params = args.to_h.slice('search', 'orderField', 'orderDirection').symbolize_keys
      Queries::AuthorizedModelQuery.new(model_class: @model_class, user: ctx[:current_user])
                                   .results(params)
    end
  end
end
