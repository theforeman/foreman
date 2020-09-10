require 'test_helper'

module Queries
  class OperatingsystemsQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        operatingsystems {
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

    let(:data) { result['data']['operatingsystems'] }

    setup do
      FactoryBot.create_list(:operatingsystem, 2)
    end

    test 'fetching operatingsystems attributes' do
      assert_empty result['errors']

      expected_count = Operatingsystem.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
