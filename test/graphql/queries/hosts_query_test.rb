require 'test_helper'

class Queries::HostsQueryTest < ActiveSupport::TestCase
  test 'fetching hosts attributes' do
    FactoryBot.create_list(:host, 2, :managed)

    query = <<-GRAPHQL
      query {
        hosts {
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

    expected_count = Host.count

    assert_empty result['errors']
    assert_equal expected_count, result['data']['hosts']['totalCount']
    assert_equal expected_count, result['data']['hosts']['edges'].count
  end
end
