require 'test_helper'

class Queries::LocationsQueryTest < ActiveSupport::TestCase
  test 'fetching locations attributes' do
    FactoryBot.create_list(:location, 2)

    query = <<-GRAPHQL
      query {
        locations {
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
    assert_equal Location.count, result['data']['locations']['edges'].count
  end
end
