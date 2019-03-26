module Types
  class Organization < BaseObject
    description 'An Organization'

    global_id_field :id
    timestamps
    field :name, String
    field :title, String

    has_many :environments, Types::Environment
    has_many :puppetclasses, Types::Puppetclass
  end
end
