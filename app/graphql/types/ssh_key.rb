module Types
  class SshKey < BaseObject
    description 'A SSH Key'

    global_id_field :id
    timestamps
    field :name, String
    field :key, String
    field :fingerprint, String
    field :length, Integer
    field :comment, String
    field :exportable_key, String, null: false, method: :to_export

    belongs_to :user, Types::User
  end
end
