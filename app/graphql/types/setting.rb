module Types
  class Setting < BaseObject
    description 'An application-wide Setting'

    global_id_field :id
    timestamps
    field :name, String
    # https://github.com/graphql/graphql-spec/issues/215
    field :value, String
    field :description, String
    field :category, String
    field :settingsType, String
    field :default, String
    field :fullName, String
    field :encrypted, Boolean, method: :encrypted?
  end
end
