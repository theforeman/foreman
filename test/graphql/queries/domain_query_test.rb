require 'test_helper'

class Queries::DomainQueryTest < ActiveSupport::TestCase
  test 'fetching domain attributes' do
    subnets = FactoryBot.create_list(:subnet_ipv4, 2)
    domain = FactoryBot.create(:domain, subnets: subnets)

    query = <<-GRAPHQL
      query (
        $id: String!
      ) {
        domain(id: $id) {
          id
          createdAt
          updatedAt
          name
          fullname
          subnets {
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
    variables = { id: domain_global_id }
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
          'totalCount' => domain.subnets.count,
          'edges' => domain.subnets.map do |subnet|
            {
              'node' => {
                'id' => Foreman::GlobalId.encode('Subnet', subnet.id)
              }
            }
          end
        }
      }
    }

    assert_empty result['errors']
    assert_equal expected, result['data']
  end
end
