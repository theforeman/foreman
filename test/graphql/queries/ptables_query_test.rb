require 'test_helper'

module Queries
  class PtablesQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        ptables {
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

    let(:data) { result['data']['ptables'] }

    setup do
      FactoryBot.create_list(:ptable, 2)
    end

    test 'fetching ptables attributes' do
      assert_empty result['errors']

      expected_count = Ptable.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
