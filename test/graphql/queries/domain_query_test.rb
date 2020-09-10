require 'test_helper'

module Queries
  class DomainQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
        $subnetsLocation: String!
      ) {
        domain(id: $id) {
          id
          createdAt
          updatedAt
          name
          fullname
          subnets(location: $subnetsLocation) {
            totalCount
            edges {
              node {
                id
              }
            }
          }
          hosts {
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

    let(:hosts) { FactoryBot.create_list(:host, 2) }
    let(:subnet_location) { FactoryBot.create(:location) }
    let(:expected_subnet) { FactoryBot.create(:subnet_ipv4, locations: [subnet_location]) }
    let(:unexpected_subnet) { FactoryBot.create(:subnet_ipv4, locations: []) }
    let(:domain) { FactoryBot.create(:domain, hosts: hosts, subnets: [expected_subnet, unexpected_subnet]) }

    let(:global_id) { Foreman::GlobalId.for(domain) }
    let(:variables) { { id: global_id, subnetsLocation: subnet_location.name } }
    let(:data) { result['data']['domain'] }

    test 'fetching domain attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal domain.created_at.utc.iso8601, data['createdAt']
      assert_equal domain.updated_at.utc.iso8601, data['updatedAt']
      assert_equal domain.name, data['name']
      assert_equal domain.fullname, data['fullname']

      assert_collection [expected_subnet], data['subnets'], type_name: 'Subnet'
      assert_collection domain.hosts, data['hosts'], type_name: 'Host'
    end
  end
end
