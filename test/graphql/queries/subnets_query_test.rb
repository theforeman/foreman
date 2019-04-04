require 'test_helper'

module Queries
  class SubnetsQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        subnets {
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

    let(:data) { result['data']['subnets'] }

    setup do
      FactoryBot.create_list(:subnet_ipv4, 2)
    end

    test 'fetching subnets attributes' do
      assert_empty result['errors']

      expected_count = Subnet.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
