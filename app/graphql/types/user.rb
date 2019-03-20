module Types
  class User < BaseObject
    description 'A User'

    global_id_field :id
    timestamps
    field :login, String, null: false
    field :admin, Boolean, null: false
    field :mail, String, null: true
    field :firstname, String, null: true
    field :lastname, String, null: true
    field :fullname, String, null: true
    field :locale, Types::LocaleEnum, null: true
    field :timezone, Types::TimezoneEnum, null: true
    field :description, String, null: true
    field :last_login_on, GraphQL::Types::ISO8601DateTime, null: true

    belongs_to :default_location, Types::Location
    belongs_to :default_organization, Types::Organization
  end
end
