require 'test_helper'

class Queries::ComputeResourcesQueryTest < ActiveSupport::TestCase
  test 'fetching compute resources attributes' do
    FactoryBot.create_list(:compute_resource, 2, :vmware, uuid: 'Solutions')

    query = <<-GRAPHQL
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

    context = { current_user: FactoryBot.create(:user, :admin) }
    result = ForemanGraphqlSchema.execute(query, variables: {}, context: context)

    expected_count = ComputeResource.count

    assert_empty result['errors']
    assert_equal expected_count, result['data']['computeResources']['totalCount']
    assert_equal expected_count, result['data']['computeResources']['edges'].count
  end
end
