require 'test_helper'

class Queries::SmartProxiesQueryTest < ActiveSupport::TestCase
  test 'fetching smartProxies attributes' do
    smart_proxy = FactoryBot.create(:smart_proxy)

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
              name
              url
            }
          }
        }
      }
    GRAPHQL

    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: {}, context: context)

    expected_smart_proxy_attributes = {
      'id' => smart_proxy.id,
      'name' => smart_proxy.name,
      'url' => smart_proxy.url
    }

    assert_includes(
      result['data']['smartProxies']['edges'].map { |e| e['node'] },
      expected_smart_proxy_attributes
    )
  end
end
