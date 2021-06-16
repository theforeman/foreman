module Types
  class Medium < BaseObject
    description 'A Medium'

    include ::Types::Concerns::MetaField

    global_id_field :id
    timestamps
    field :name, String
    field :path, String
    field :os_family, Types::OsFamilyEnum

    has_many :operatingsystems, Types::Operatingsystem
    has_many :hosts, Types::Host
    has_many :locations, Types::Location
    has_many :organizations, Types::Organization
  end
end
