require 'test_helper'

module Queries
  class HostsQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        hosts {
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

    let(:data) { result['data']['hosts'] }

    setup do
      FactoryBot.create_list(:host, 2, :managed)
    end

    test 'fetching hosts attributes' do
      assert_empty result['errors']

      expected_count = Host.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
