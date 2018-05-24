class ForemanGraphqlSchema < GraphQL::Schema
  # Set up the graphql-batch gem
  lazy_resolve(Promise, :sync)
  use GraphQL::Batch

  query(Types::Query)
end
