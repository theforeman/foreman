module Types
  class BaseObject < GraphQL::Types::Relay::BaseObject
    implements GraphQL::Relay::Node.interface

    connection_type_class Connections::BaseConnection

    class << self
      def timestamps
        field :created_at, GraphQL::Types::ISO8601DateTime, null: true
        field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
      end

      def has_many(name, type, null: true, resolver: nil)
        if resolver
          field name, type.connection_type, null: null, resolver: resolver
        else
          field name, type.connection_type, null: null,
            resolve: proc { |object| CollectionLoader.for(object.class, name).load(object) }
        end
      end

      def belongs_to(name, type, null: true, resolver: nil)
        if resolver
          field name, type, null: null, resolver: resolver
        else
          field name, type, null: null,
            resolve: (proc do |object|
              foreign_key = object.class.reflect_on_association(name).foreign_key
              RecordLoader.for(type.model_class).load(object.send(foreign_key))
            end)
        end
      end

      def model_class
        "::#{self.to_s.demodulize}".safe_constantize
      end
    end
  end
end
