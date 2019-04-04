require 'test_helper'

module Queries
  class ComputeAttributesQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        computeAttributes {
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

    let(:data) { result['data']['computeAttributes'] }

    setup do
      compute_resource = FactoryBot.create(:compute_resource, :vmware, uuid: 'Solutions')
      FactoryBot.create(:compute_profile, :with_compute_attribute, compute_resource: compute_resource)
    end

    test 'fetching compute resources attributes' do
      assert_empty result['errors']

      expected_count = ComputeAttribute.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
