require 'test_helper'

class Queries::PersonalAccessTokensQueryTest < ActiveSupport::TestCase
  test 'fetching personalAccessTokens attributes' do
    FactoryBot.create_list(:personal_access_token, 2)

    query = <<-GRAPHQL
      query {
        personalAccessTokens {
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

    expected_count = PersonalAccessToken.count

    assert_empty result['errors']
    assert_equal expected_count, result['data']['personalAccessTokens']['totalCount']
    assert_equal expected_count, result['data']['personalAccessTokens']['edges'].count
  end
end
