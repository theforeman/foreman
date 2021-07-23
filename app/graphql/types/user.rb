module Types
  class User < BaseObject
    description 'A User'

    global_id_field :id
    timestamps
    field :login, String
    field :admin, Boolean
    field :mail, String
    field :firstname, String
    field :lastname, String
    field :fullname, String
    field :locale, Types::LocaleEnum
    field :timezone, Types::TimezoneEnum
    field :description, String
    field :last_login_on, GraphQL::Types::ISO8601DateTime

    belongs_to :default_location, Types::Location
    belongs_to :default_organization, Types::Organization
    has_many :personal_access_tokens, Types::PersonalAccessToken
    has_many :ssh_keys, Types::SshKey
    has_many :usergroups, Types::Usergroup
    has_many :permissions, Types::Permission
  end
end
