require 'test_helper'

module Queries
  class SettingsQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        settings {
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
              name
            }
          }
        }
      }
      GRAPHQL
    end

    let(:data) { result['data']['settings'] }

    test 'fetch settings' do
      assert_empty result['errors']

      expected_count = Setting.count
      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
