module Types
  class Operatingsystem < BaseObject
    description 'An Operatingsystem'

    global_id_field :id
    timestamps
    field :name, String
    field :title, String
    field :type, String
    field :fullname, String
    field :family, Types::OsFamilyEnum

    has_many :hosts, Types::Host
    has_many :media, Types::Medium
  end
end
