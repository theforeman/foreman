require 'test_helper'

module Queries
  class FactNamesQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        factNames {
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

    let(:data) { result['data']['factNames'] }

    setup do
      FactoryBot.create_list(:fact_name, 2)
    end

    test 'fetching fact names attributes' do
      assert_empty result['errors']

      expected_count = FactName.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
