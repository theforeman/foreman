require 'test_helper'

class Queries::SmartProxiesQueryTest < ActiveSupport::TestCase
  test 'fetching smart proxies attributes' do
    FactoryBot.create_list(:smart_proxy, 2)

    query = <<-GRAPHQL
      query {
        smartProxies {
          totalCount
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

    expected_count = SmartProxy.count

    assert_empty result['errors']
    assert_equal expected_count, result['data']['smartProxies']['totalCount']
    assert_equal expected_count, result['data']['smartProxies']['edges'].count
  end
end
