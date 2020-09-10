module Mutations
  module Settings
    class Update < UpdateMutation
      graphql_name 'UpdateSettingMutation'
      description 'Updates a setting'

      # https://github.com/graphql/graphql-spec/blob/master/rfcs/InputUnion.md
      argument :value, String, required: true

      field :setting, Types::Setting, 'Setting', null: true

      def assign_attributes(object, params)
        object.parse_string_value(params[:value])
      end

      def self.save_object(resource)
        return super resource unless resource.errors.any?
        {
          result_key => resource,
          :errors => map_errors_to_path(resource),
        }
      end
    end
  end
end
