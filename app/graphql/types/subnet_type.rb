Types::SubnetType = GraphQL::ObjectType.define do
  name 'Subnet'
  description 'A Subnet'

  backed_by_model :subnet do
    attr :id
    attr :name
    attr :type
    attr :network
    attr :mask
    attr :priority
    attr :vlanid
    attr :gateway
    attr :dns_primary
    attr :dns_secondary
    attr :from
    attr :to
    attr :ipam
    attr :boot_mode
    attr :created_at
    attr :updated_at
  end

  field :networkAddress, types.String, resolve: proc { |obj| obj.network_address }
  field :networkType, types.String, resolve: proc { |obj| obj.network_type }
  field :cidr, types.String, resolve: proc { |obj| obj.cidr }
end
