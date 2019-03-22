require 'test_helper'

class Queries::ComputeAttributesQueryTest < ActiveSupport::TestCase
  test 'fetching compute resources attributes' do
    compute_resource = FactoryBot.create(:compute_resource, :vmware, uuid: 'Solutions')
    FactoryBot.create(:compute_profile, :with_compute_attribute, compute_resource: compute_resource)

    query = <<-GRAPHQL
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

    context = { current_user: FactoryBot.create(:user, :admin) }
    result = ForemanGraphqlSchema.execute(query, variables: {}, context: context)

    expected_count = ComputeAttribute.count

    assert_empty result['errors']
    assert_equal expected_count, result['data']['computeAttributes']['totalCount']
    assert_equal expected_count, result['data']['computeAttributes']['edges'].count
  end
end
