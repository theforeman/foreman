class ForemanGraphqlSchema < GraphQL::Schema
  # Set up the graphql-batch gem
  lazy_resolve(Promise, :sync)
  use GraphQL::Batch

  query(Types::Query)
  mutation(Types::Mutation)

  if Rails.env.production?
    rescue_from ActiveRecord::RecordInvalid, &:message
    rescue_from ActiveRecord::Rollback, &:message
    rescue_from StandardError, &:message
    rescue_from ActiveRecord::RecordNotUnique, &:message
    rescue_from ActiveRecord::RecordNotFound, &:message
  end

  def self.id_from_object(object, type_definition, query_ctx)
    name = if type_definition.respond_to?(:graphql_name)
             type_definition.graphql_name.gsub('_', '::')
           else
             type_definition.name
           end
    Foreman::GlobalId.encode(name, object.id)
  end

  def self.object_from_id(id, query_ctx)
    return unless id.present?

    _, model_class_name, item_id = Foreman::GlobalId.decode(id)
    model_class = ForemanGraphqlSchema.types.fetch(model_class_name.gsub('::', '_'))&.model_class

    return unless model_class

    RecordLoader.for(model_class).load(item_id.to_i)
  end

  def self.resolve_type(_, object, _)
    klass = object.class
    custom_name = klass.name.gsub('::', '_')
    klass.try(:graphql_type)&.safe_constantize || types[klass.name] || types[custom_name]
  end
end
