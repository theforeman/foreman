require 'test_helper'

module Queries
  class ComputeResourcesQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        computeResources {
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

    let(:data) { result['data']['computeResources'] }

    setup do
      FactoryBot.create_list(:compute_resource, 2, :vmware, uuid: 'Solutions')
    end

    test 'fetching compute resources attributes' do
      assert_empty result['errors']

      expected_count = ComputeResource.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
