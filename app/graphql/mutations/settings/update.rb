module Mutations
  module Settings
    class Update < UpdateMutation
      graphql_name 'UpdateSettingMutation'
      description 'Updates a setting'

      argument :id, ID, required: true
      argument :value, String

      field :setting, Types::Setting, 'Setting', null: true
    end
  end
end
