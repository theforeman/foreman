require 'test_helper'

module Queries
  class UsergroupsQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        usergroups {
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

    let(:data) { result['data']['usergroups'] }

    setup do
      FactoryBot.create_list(:usergroup, 2)
    end

    test 'fetching usergroups attributes' do
      assert_empty result['errors']

      expected_count = Usergroup.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
