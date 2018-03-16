require 'test_helper'

class Queries::DomainQueryTest < ActiveSupport::TestCase
  test 'fetching domain attributes' do
    subnet = FactoryBot.create(:subnet_ipv4)
    domain = FactoryBot.create(:domain, subnets: [subnet])

    query = <<-GRAPHQL
      query {
        domain(id: #{domain.id}) {
          id
          name
          fullname
          subnets(type: "#{subnet.type}") {
            edges {
              node {
                id
                name
              }
            }
          }
        }
      }
    GRAPHQL

    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: {}, context: context)

    expected_domain_attributes = {
      'id' => domain.id,
      'name' => domain.name,
      'fullname' => domain.fullname,
      'subnets' => {
        'edges' => [
          'node' => {
            'id' => subnet.id,
            'name' => subnet.name
          }
        ]
      }
    }

    assert_equal expected_domain_attributes, result['data']['domain']
  end
end
