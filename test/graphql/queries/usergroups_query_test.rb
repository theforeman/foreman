require 'test_helper'

class Queries::UsergroupsQueryTest < ActiveSupport::TestCase
  test 'fetching usergroups attributes' do
    FactoryBot.create_list(:usergroup, 2)

    query = <<-GRAPHQL
      query {
        usergroups {
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
    assert_equal Usergroup.count, result['data']['usergroups']['edges'].count
  end
end
