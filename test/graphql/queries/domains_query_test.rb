require 'test_helper'

module Queries
  class DomainsQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        domains {
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

    let(:data) { result['data']['domains'] }

    setup do
      FactoryBot.create_list(:domain, 2)
    end

    test 'fetching domains attributes' do
      assert_empty result['errors']

      expected_count = Domain.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
