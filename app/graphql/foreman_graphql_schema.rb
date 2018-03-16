ForemanGraphqlSchema = GraphQL::Schema.define do
  # Set up the graphql-batch gem
  lazy_resolve(Promise, :sync)
  use GraphQL::Batch

  # Set up the graphql-activerecord gem
  instrument(:field, GraphQL::Models::Instrumentation.new)

  mutation(Types::Mutation)
  query(Types::Query)
end
