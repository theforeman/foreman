module Types
  class Ptable < BaseObject
    description 'A partition table'

    global_id_field :id
    timestamps
    field :name, String
    field :layout, String
    field :locked, Boolean
    field :os_family, Types::OsFamilyEnum

    has_many :operatingsystems, Types::Operatingsystem
    has_many :hosts, Types::Host
    has_many :locations, Types::Location
    has_many :organizations, Types::Organization
  end
end
