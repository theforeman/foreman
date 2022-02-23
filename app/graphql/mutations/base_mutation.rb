module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    class << self
      def argument(*args, **kwargs, &block)
        required = kwargs.key?(:required) ? kwargs[:required] : attribute_required?(args.first)
        super(*args, **kwargs.except(:required), required: required, &block)
      end

      def resource_class(new_resource_class = nil)
        if new_resource_class
          @resource_class = new_resource_class
        else
          @resource_class ||= "::#{to_s.split('::')[-2].singularize}".safe_constantize
        end
      end

      private

      def attribute_required?(attribute)
        GraphqlAttribute.for(resource_class).required?(attribute)
      end
    end

    object_class Types::BaseObject
    input_object_class Types::BaseInputObject

    private

    delegate :resource_class, to: :class

    def authorize!(resource, action)
      user = context[:current_user]
      authorizer = Authorizer.new(user)
      permission_name = resource.permission_name(action)

      return if action == :create && authorizer.can?(permission_name)
      return if action != :create && authorizer.can?(permission_name, resource)

      raise GraphQL::ExecutionError.new(
        _('Unauthorized. You do not have the required permission %s.') % permission_name
      )
    end

    def validate_object(resource)
      unless resource.is_a?(resource_class)
        raise GraphQL::ExecutionError.new("Resource mismatch, expected #{resource_class.name}, got #{resource.class.name}")
      end
    end

    def load_object_by(id:)
      object = GraphQL::Batch.batch { ForemanGraphqlSchema.object_from_id(id, context) }

      raise GraphQL::ExecutionError.new(_('Could not resolve ID.')) unless object

      validate_object(object)

      object
    end

    def save_object(resource)
      User.as(context[:current_user]) do
        errors = if resource.save
                   []
                 else
                   resource.restore_attributes if resource.persisted?
                   map_errors_to_path(resource)
                 end

        {
          result_key => resource,
          :errors => errors,
        }
      end
    end

    def map_errors_to_path(resource)
      resource.errors.map do |error|
        {
          path: ['attributes', error.attribute.to_s.camelize(:lower)],
          message: error.message,
        }
      end
    end

    def result_key
      keys = self.class.fields.select { |field_name, field| field.owner == self.class }.values.map(&:method_sym)
      raise GraphQL::ExecutionError.new("Could not detect result key for #{self.class}. Did you define a result field for the mutation?") unless keys.any?
      raise GraphQL::ExecutionError.new("Could not detect result key for #{self.class}. Possible values are #{keys.to_sentence}.") if keys.size > 1
      keys.first
    end
  end
end
