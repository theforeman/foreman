module Types
  class BaseObject < GraphQL::Schema::Object
    implements GraphQL::Types::Relay::Node

    connection_type_class Connections::BaseConnection

    class << self
      def field(*args, **kwargs, &block)
        null = kwargs.key?(:null) ? kwargs[:null] : nullable?(args.first)
        super(*args, **kwargs.except(:null), null: null, &block)
      end

      def timestamps
        field :created_at, GraphQL::Types::ISO8601DateTime
        field :updated_at, GraphQL::Types::ISO8601DateTime
      end

      def has_many(name, type, resolver: nil, **kwargs)
        resolver ||= Resolvers::Generic.for(self).association(name)
        field name, type.connection_type, resolver: resolver, **kwargs.except(:resolver)
      end

      def belongs_to(name, type, resolver: nil, foreign_key: nil, **kwargs)
        if resolver
          field name, type, resolver: resolver, **kwargs.except(:resolver, :foreign_key)
        else
          resolver_method = "resolve_#{name}".to_sym
          define_method(resolver_method) do
            reflection = object.class.reflect_on_association(name)
            foreign_key ||= reflection.foreign_key
            target_class = reflection&.polymorphic? ? object.public_send(reflection.foreign_type).constantize : type.model_class
            RecordLoader.for(target_class).load(object.send(foreign_key))
          end
          field name, type, resolver_method: resolver_method, **kwargs.except(:resolver, :foreign_key)
        end
      end

      def model_class(new_model_class = nil)
        if new_model_class
          ensure_resolvable_type(new_model_class)
          @model_class = new_model_class
        else
          @model_class ||= "::#{to_s.demodulize}".safe_constantize
        end
      end

      # Some objects are wrappers around models
      def record_for(object)
        object
      end

      private

      def nullable?(attribute)
        !GraphqlAttribute.for(model_class).required?(attribute)
      end

      def ensure_resolvable_type(klass)
        if klass.respond_to?(:graphql_type)
          klass.graphql_type(to_s) unless klass.graphql_type
        else
          graphql_name(klass.name.gsub('::', '_'))
        end
      end
    end
  end
end
