require 'test_helper'

class Queries::SmartProxiesQueryTest < ActiveSupport::TestCase
  test 'fetching smart proxies attributes' do
    FactoryBot.create_list(:smart_proxy, 2)

    query = <<-GRAPHQL
      query {
        smartProxies {
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
    assert_equal SmartProxy.count, result['data']['smartProxies']['edges'].count
  end
end
