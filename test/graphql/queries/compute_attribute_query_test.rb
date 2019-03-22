require 'test_helper'

class Queries::ComputeAttributeQueryTest < ActiveSupport::TestCase
  test 'fetching compute attribute attributes' do
    compute_resource = FactoryBot.create(:compute_resource, :vmware, uuid: 'Solutions')
    FactoryBot.create(:compute_profile, :with_compute_attribute, compute_resource: compute_resource)
    compute_attribute = compute_resource.compute_attributes.first

    query = <<-GRAPHQL
      query (
        $id: String!
      ) {
        computeAttribute(id: $id) {
          id
          createdAt
          updatedAt
          name
          computeResource {
            id
          }
        }
      }
    GRAPHQL

    compute_attribute_global_id = Foreman::GlobalId.for(compute_attribute)
    variables = { id: compute_attribute_global_id }
    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
    expected = {
      'computeAttribute' => {
        'id' => compute_attribute_global_id,
        'createdAt' => compute_attribute.created_at.utc.iso8601,
        'updatedAt' => compute_attribute.updated_at.utc.iso8601,
        'name' => compute_attribute.name,
        'computeResource' => {
          'id' => Foreman::GlobalId.for(compute_attribute.compute_resource)
        }
      }
    }

    assert_empty result['errors']
    assert_equal expected, result['data']
  end
end
