require 'test_helper'

module Queries
  class SubnetQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
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
          domains {
            totalCount
            edges {
              node {
                id
              }
            }
          }
        }
      }
      GRAPHQL
    end

    let(:domains) { FactoryBot.create_list(:domain, 2) }
    let(:subnet) { FactoryBot.create(:subnet_ipv4, domains: domains) }

    let(:global_id) { Foreman::GlobalId.encode('Subnet', subnet.id) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['subnet'] }

    test 'fetching subnet attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal subnet.created_at.utc.iso8601, data['createdAt']
      assert_equal subnet.updated_at.utc.iso8601, data['updatedAt']
      assert_equal subnet.name, data['name']
      assert_equal subnet.type, data['type']
      assert_equal subnet.network, data['network']
      assert_equal subnet.mask, data['mask']
      assert_equal subnet.priority, data['priority']
      assert_equal subnet.vlanid, data['vlanid']
      assert_equal subnet.gateway, data['gateway']
      assert_equal subnet.dns_primary, data['dnsPrimary']
      assert_equal subnet.dns_secondary, data['dnsSecondary']
      assert_equal subnet.from, data['from']
      assert_equal subnet.to, data['to']
      assert_equal subnet.ipam, data['ipam']
      assert_equal subnet.boot_mode, data['bootMode']
      assert_equal subnet.network_address, data['networkAddress']
      assert_equal subnet.network_type, data['networkType']
      assert_equal subnet.cidr, data['cidr']

      assert_collection subnet.domains, data['domains']
    end
  end
end
