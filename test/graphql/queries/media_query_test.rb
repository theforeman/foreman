require 'test_helper'

module Queries
  class MediaQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        media {
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

    let(:data) { result['data']['media'] }

    setup do
      FactoryBot.create_list(:medium, 2)
    end

    test 'fetching media attributes' do
      assert_empty result['errors']

      expected_count = Medium.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
