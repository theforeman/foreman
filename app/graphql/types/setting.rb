module Types
  class Setting < BaseObject
    description 'An application-wide Setting'

    field :id, "ID", null: false
    field :name, String
    # https://github.com/graphql/graphql-spec/issues/215
    field :value, String
    field :description, String
    field :category, String
    field :settingsType, String, method: :settings_type
    field :default, String
    field :fullName, String, method: :full_name
    field :encrypted, Boolean, method: :encrypted?
    field :updated_at, GraphQL::Types::ISO8601DateTime

    def id
      context.schema.id_from_object(object, ::Setting, context)
    end

    private

    def nullable?(attribute)
      attribute.to_s == 'value'
    end

    def model_class
      SettingPresenter
    end
  end
end
