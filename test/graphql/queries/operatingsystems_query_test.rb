require 'test_helper'

class Queries::OperatingsystemsQueryTest < ActiveSupport::TestCase
  test 'fetching operatingsystems attributes' do
    FactoryBot.create_list(:operatingsystem, 2)

    query = <<-GRAPHQL
      query {
        operatingsystems {
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

    expected_count = Operatingsystem.count

    assert_empty result['errors']
    assert_equal expected_count, result['data']['operatingsystems']['totalCount']
    assert_equal expected_count, result['data']['operatingsystems']['edges'].count
  end
end
