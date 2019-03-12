module Types
  class Subnet < BaseObject
    description 'A Subnet'

    global_id_field :id
    timestamps
    field :name, String, null: true
    field :type, String, null: true
    field :network, String, null: true
    field :mask, String, null: true
    field :priority, Int, null: true
    field :vlanid, Int, null: true
    field :gateway, String, null: true
    field :dns_primary, String, null: true
    field :dns_secondary, String, null: true
    field :from, String, null: true
    field :to, String, null: true
    field :ipam, String, null: true
    field :boot_mode, String, null: true
    field :network_address, String, null: true
    field :network_type, String, null: true
    field :cidr, Int, null: true
  end
end
