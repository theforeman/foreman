require 'test_helper'

class Queries::DomainQueryTest < ActiveSupport::TestCase
  test 'fetching domain attributes' do
    location = FactoryBot.create(:location)
    expected_subnet = FactoryBot.create(:subnet_ipv4, locations: [location])
    unexpected_subnet = FactoryBot.create(:subnet_ipv4, locations: [])
    domain = FactoryBot.create(:domain, subnets: [expected_subnet, unexpected_subnet])

    query = <<-GRAPHQL
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
        }
      }
    GRAPHQL

    domain_global_id = Foreman::GlobalId.for(domain)
    variables = { id: domain_global_id, subnetsLocation: location.name }
    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
    expected = {
      'domain' => {
        'id' => domain_global_id,
        'createdAt' => domain.created_at.utc.iso8601,
        'updatedAt' => domain.updated_at.utc.iso8601,
        'name' => domain.name,
        'fullname' => domain.fullname,
        'subnets' => {
          'totalCount' => 1,
          'edges' => [
            {
              'node' => {
                'id' => Foreman::GlobalId.encode('Subnet', expected_subnet.id)
              }
            }
          ]
        }
      }
    }

    assert_empty result['errors']
    assert_equal expected, result['data']
  end
end
