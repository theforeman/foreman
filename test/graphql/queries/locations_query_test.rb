require 'test_helper'

module Queries
  class LocationsQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        locations {
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

    let(:data) { result['data']['locations'] }

    setup do
      FactoryBot.create_list(:location, 2)
    end

    test 'fetching locations attributes' do
      assert_empty result['errors']

      expected_count = Location.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
