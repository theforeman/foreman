require 'test_helper'

class Queries::EnvironmentsQueryTest < ActiveSupport::TestCase
  test 'fetching environments attributes' do
    FactoryBot.create_list(:environment, 2)

    query = <<-GRAPHQL
      query {
        environments {
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

    expected_count = Environment.count

    assert_empty result['errors']
    assert_equal expected_count, result['data']['environments']['totalCount']
    assert_equal expected_count, result['data']['environments']['edges'].count
  end
end
