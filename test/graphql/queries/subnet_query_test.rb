require 'test_helper'

class Queries::SubnetQueryTest < ActiveSupport::TestCase
  test 'fetching subnet attributes' do
    subnet = FactoryBot.create(:subnet_ipv4)

    query = <<-GRAPHQL
      query (
        $id: String!
      ) {
        subnet(id: $id) {
          id
          createdAt
          updatedAt
          name
          type
          network
          mask
          priority
          vlanid
          gateway
          dnsPrimary
          dnsSecondary
          from
          to
          ipam
          bootMode
          networkAddress
          networkType
          cidr
        }
      }
    GRAPHQL

    subnet_global_id = Foreman::GlobalId.encode('Subnet', subnet.id)
    variables = { id: subnet_global_id }
    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
    expected = {
      'subnet' => {
        'id' => subnet_global_id,
        'createdAt' => subnet.created_at.utc.iso8601,
        'updatedAt' => subnet.updated_at.utc.iso8601,
        'name' => subnet.name,
        'type' => subnet.type,
        'network' => subnet.network,
        'mask' => subnet.mask,
        'priority' => subnet.priority,
        'vlanid' => subnet.vlanid,
        'gateway' => subnet.gateway,
        'dnsPrimary' => subnet.dns_primary,
        'dnsSecondary' => subnet.dns_secondary,
        'from' => subnet.from,
        'to' => subnet.to,
        'ipam' => subnet.ipam,
        'bootMode' => subnet.boot_mode,
        'networkAddress' => subnet.network_address,
        'networkType' => subnet.network_type,
        'cidr' => subnet.cidr
      }
    }

    assert_empty result['errors']
    assert_equal expected, result['data']
  end
end
