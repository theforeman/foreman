module Mutations
  module Settings
    class Update < BaseMutation
      graphql_name 'UpdateSettingMutation'
      description 'Updates a setting'

      # https://github.com/graphql/graphql-spec/blob/master/rfcs/InputUnion.md
      argument :id, ID, required: false
      argument :name, String, required: false
      argument :value, String, required: true

      field :errors, [Types::AttributeError], null: false
      field :setting, Types::Setting, description: 'Setting', null: true

      def self.resource_class
        SettingPresenter
      end

      def resolve(params)
        authorize!

        if params[:name]
          name = params[:name]
        else
          _, _, name = Foreman::GlobalId.decode(params[:id])
        end

        definition = Foreman.settings.find(name)
        validate_object(definition)

        record = Foreman.settings.set_user_value(definition.name, params[:value])
        save_object(definition, record)
      end

      def save_object(definition, record)
        User.as(context[:current_user]) do
          errors = if record.save
                     []
                   else
                     map_errors_to_path(record)
                   end
          {
            :setting => definition,
            :errors => errors,
          }
        end
      end

      private

      def authorize!
        return if context[:current_user]&.can?(:edit_settings)

        raise GraphQL::ExecutionError.new(
          _('Unauthorized. You do not have the required permission %s.') % 'edit_settings'
        )
      end
    end
  end
end
