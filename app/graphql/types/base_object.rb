module Types
  class BaseObject < GraphQL::Types::Relay::BaseObject
    implements GraphQL::Relay::Node.interface

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

      def has_many(name, type, resolver: nil)
        if resolver
          field name, type.connection_type, resolver: resolver
        else
          field name, type.connection_type,
            resolve: proc { |object| CollectionLoader.for(object.class, name).load(object) }
        end
      end

      def belongs_to(name, type, resolver: nil)
        if resolver
          field name, type, resolver: resolver
        else
          field name, type,
            resolve: (proc do |object|
              foreign_key = object.class.reflect_on_association(name).foreign_key
              RecordLoader.for(type.model_class).load(object.send(foreign_key))
            end)
        end
      end

      def model_class(new_model_class = nil)
        if new_model_class
          @model_class = new_model_class
        else
          @model_class ||= "::#{self.to_s.demodulize}".safe_constantize
        end
      end

      private

      def nullable?(attribute)
        !GraphqlAttribute.for(model_class).required?(attribute)
      end
    end
  end
end
