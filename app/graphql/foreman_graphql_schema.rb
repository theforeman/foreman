class ForemanGraphqlSchema < GraphQL::Schema
  # Set up the graphql-batch gem
  lazy_resolve(Promise, :sync)
  use GraphQL::Batch

  query(Types::Query)
  mutation(Types::Mutation)

  rescue_from ActiveRecord::RecordInvalid, &:message
  rescue_from ActiveRecord::Rollback, &:message
  rescue_from StandardError, &:message
  rescue_from ActiveRecord::RecordNotUnique, &:message
  rescue_from ActiveRecord::RecordNotFound, &:message

  def self.id_from_object(object, type_definition, query_ctx)
    Foreman::GlobalId.encode(type_definition.name, object.id)
  end

  def self.object_from_id(id, query_ctx)
    return unless id.present?

    _, type_name, item_id = Foreman::GlobalId.decode(id)
    model_class = type_name.safe_constantize

    return unless model_class

    RecordLoader.for(model_class).load(item_id.to_i)
  end

  def self.resolve_type(_, obj, _)
    types[obj.class.name]
  end
end
