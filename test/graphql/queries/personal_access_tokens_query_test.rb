require 'test_helper'

module Queries
  class PersonalAccessTokensQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
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
    end

    let(:data) { result['data']['personalAccessTokens'] }

    setup do
      FactoryBot.create_list(:personal_access_token, 2)
    end

    test 'fetching personalAccessTokens attributes' do
      assert_empty result['errors']

      expected_count = PersonalAccessToken.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
