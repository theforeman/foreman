require 'test_helper'

module Queries
  class OrganizationsQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        organizations {
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

    let(:data) { result['data']['organizations'] }

    setup do
      FactoryBot.create_list(:organization, 2)
    end

    test 'fetching organizations attributes' do
      assert_empty result['errors']

      expected_count = Organization.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
