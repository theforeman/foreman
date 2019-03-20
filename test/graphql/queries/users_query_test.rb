require 'test_helper'

class Queries::UsersQueryTest < ActiveSupport::TestCase
  test 'fetching users attributes' do
    FactoryBot.create_list(:user, 2)

    query = <<-GRAPHQL
      query {
        users {
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

    expected_count = User.count

    assert_empty result['errors']
    assert_equal expected_count, result['data']['users']['totalCount']
    assert_equal expected_count, result['data']['users']['edges'].count
  end
end
