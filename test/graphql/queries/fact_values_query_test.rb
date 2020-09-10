require 'test_helper'

module Queries
  class FactValuesQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        factValues {
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

    let(:data) { result['data']['factValues'] }

    setup do
      FactoryBot.create_list(:fact_value, 2)
    end

    test 'fetching fact values attributes' do
      assert_empty result['errors']

      expected_count = FactValue.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
