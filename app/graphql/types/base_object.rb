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

      def model_class
        "::#{self.to_s.demodulize}".safe_constantize
      end

      private

      def nullable?(attribute)
        return false if model_class.columns_hash[attribute.to_s]&.null == false

        return false if model_class.validators_on(attribute).find do |v|
          v.is_a?(ActiveModel::Validations::PresenceValidator) && v.options.none? { |o| [:if, :unless].include?(o) }
        end

        reflection = model_class.reflect_on_association(attribute)
        return false if reflection && reflection.macro == :belongs_to && nullable?(reflection.foreign_key)

        true
      end
    end
  end
end
