require 'test_helper'

module Queries
  class HostgroupsQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        hostgroups {
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

    let(:data) { result['data']['hostgroups'] }

    setup do
      FactoryBot.create_list(:hostgroup, 2)
    end

    test 'fetching hostgroups attributes' do
      assert_empty result['errors']

      expected_count = Hostgroup.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
