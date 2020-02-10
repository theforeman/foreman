module Types
  class Operatingsystem < BaseObject
    description 'An Operatingsystem'

    global_id_field :id
    timestamps
    field :name, String
    field :title, String
    field :major, String
    field :minor, String
    field :releaseName, String
    field :type, String
    field :fullname, String
    field :family, Types::OsFamilyEnum
    field :description, String
    field :passwordHash, Types::PasswordHashEnum

    has_many :hosts, Types::Host
    has_many :media, Types::Medium
    has_many :architectures, Types::Architecture
    has_many :ptables, Types::Ptable
  end
end
