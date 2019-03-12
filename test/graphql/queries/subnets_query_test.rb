require 'test_helper'

class Queries::SubnetsQueryTest < ActiveSupport::TestCase
  test 'fetching subnets attributes' do
    FactoryBot.create_list(:subnet_ipv4, 2)

    query = <<-GRAPHQL
      query {
        subnets {
          pageInfo {
            startCursor
            endCursor
            hasNextPage
            hasPreviousPage
          }
          edges {
            cursor
            node {
              id
            }
          }
        }
      }
    GRAPHQL

    context = { current_user: FactoryBot.create(:user, :admin) }
    result = ForemanGraphqlSchema.execute(query, variables: {}, context: context)

    assert_empty result['errors']
    assert_equal Subnet.count, result['data']['subnets']['edges'].count
  end
end
