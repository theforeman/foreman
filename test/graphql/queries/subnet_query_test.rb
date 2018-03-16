require 'test_helper'

class Queries::SubnetQueryTest < ActiveSupport::TestCase
  test 'fetching subnet attributes' do
    subnet = FactoryBot.create(:subnet_ipv4)

    query = <<-GRAPHQL
      query {
        subnet(id: #{subnet.id}) {
          id
          name
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
          createdAt
          updatedAt
          networkAddress
          networkType
          cidr
        }
      }
    GRAPHQL

    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: {}, context: context)

    expected_subnet_attributes = {
      'id' => subnet.id,
      'name' => subnet.name,
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
      'createdAt' => subnet.created_at.utc.iso8601,
      'updatedAt' => subnet.updated_at.utc.iso8601,
      'networkAddress' => subnet.network_address,
      'networkType' => subnet.network_type,
      'cidr' => subnet.cidr.to_s
    }

    assert_equal expected_subnet_attributes, result['data']['subnet']
  end
end
