require 'test_helper'

module Queries
  class ArchitecturesQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        architectures {
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

    let(:data) { result['data']['architectures'] }

    setup do
      FactoryBot.create_list(:architecture, 2)
    end

    test 'fetching architectures attributes' do
      assert_empty result['errors']

      expected_count = Architecture.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
