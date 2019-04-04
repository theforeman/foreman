require 'test_helper'

module Queries
  class EnvironmentsQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        environments {
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

    let(:data) { result['data']['environments'] }

    setup do
      FactoryBot.create_list(:environment, 2)
    end

    test 'fetching environments attributes' do
      assert_empty result['errors']

      expected_count = Environment.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
