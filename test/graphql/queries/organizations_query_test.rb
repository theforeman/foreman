require 'test_helper'

class Queries::OrganizationsQueryTest < ActiveSupport::TestCase
  test 'fetching organizations attributes' do
    FactoryBot.create_list(:organization, 2)

    query = <<-GRAPHQL
      query {
        organizations {
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

    expected_count = Organization.count

    assert_empty result['errors']
    assert_equal expected_count, result['data']['organizations']['totalCount']
    assert_equal expected_count, result['data']['organizations']['edges'].count
  end
end
