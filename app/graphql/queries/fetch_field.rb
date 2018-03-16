module Queries
  class FetchField < GraphQL::Function
    attr_reader :type

    argument(:id, !types.Int, 'ID for Record')

    def initialize(model_class:, type:)
      @model_class = model_class
      @type = type
    end

    def call(_, args, ctx)
      Queries::AuthorizedModelQuery.new(model_class: @model_class, user: ctx[:current_user])
                                   .find_by(id: args['id'])
    end
  end
end
