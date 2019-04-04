require 'test_helper'

module Queries
  class SmartProxiesQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        smartProxies {
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

    let(:data) { result['data']['smartProxies'] }

    setup do
      FactoryBot.create_list(:smart_proxy, 2)
    end

    test 'fetching smart proxies attributes' do
      assert_empty result['errors']

      expected_count = SmartProxy.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
