require 'test_helper'

class Queries::LocationsQueryTest < ActiveSupport::TestCase
  test 'fetching locations attributes' do
    FactoryBot.create_list(:location, 2)

    query = <<-GRAPHQL
      query {
        locations {
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

    expected_count = Location.count

    assert_empty result['errors']
    assert_equal expected_count, result['data']['locations']['totalCount']
    assert_equal expected_count, result['data']['locations']['edges'].count
  end
end
