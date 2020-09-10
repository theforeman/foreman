require 'test_helper'

module Queries
  class UsersQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
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
    end

    let(:data) { result['data']['users'] }

    setup do
      FactoryBot.create_list(:user, 2)
    end

    test 'fetching users attributes' do
      assert_empty result['errors']

      expected_count = User.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
