module Types
  class Subnet < BaseObject
    description 'A Subnet'

    global_id_field :id
    timestamps
    field :name, String
    field :type, String
    field :network, String
    field :mask, String
    field :priority, Int
    field :vlanid, Int
    field :gateway, String
    field :dns_primary, String
    field :dns_secondary, String
    field :from, String
    field :to, String
    field :ipam, String
    field :boot_mode, String
    field :network_address, String
    field :network_type, String
    field :cidr, Int

    has_many :domains, Types::Domain
  end
end
